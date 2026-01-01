import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:abstract_bloc/extensions/_all.dart';
import 'package:abstract_bloc/models/cursor_pagination.dart';

/// An abstract Cubit for managing list-based state with support for loading,
/// refreshing, pagination, filtering, and caching.
///
/// This class provides a complete solution for managing lists of data with:
/// - Initial load, refresh, and load-more (pagination) operations
/// - Support for both network and cached data sources
/// - Filter management with snapshot/revert capabilities
/// - Lifecycle hooks for customization
///
/// ## Usage
///
/// Extend this class and implement [resolveData] to fetch your data:
///
/// ```dart
/// class UsersCubit extends AbstractListCubit<UsersState> {
///   final UsersRepository _repository;
///
///   UsersCubit(this._repository) : super(UsersState.initial());
///
///   @override
///   Future<Result> resolveData() async {
///     return _repository.getUsers(state.searchModel);
///   }
/// }
/// ```
///
/// ## State Requirements
///
/// The state type [S] must extend [AbstractListState]. For filtering support,
/// use [AbstractListFilterableState]. For pagination, use
/// [AbstractListFilterablePaginatedState].
///
/// ## Filter Management
///
/// The cubit supports a snapshot/revert pattern for filter management:
/// 1. Call [snapshot] to save current filters before user modifications
/// 2. Use [update] to modify filters (marks state as dirty)
/// 3. Call [load] to apply filters and fetch new data
/// 4. Call [revert] to restore previous filters if user cancels
/// 5. Call [reset] to restore initial filters
abstract class AbstractListCubit<S extends AbstractListState> extends Cubit<S> {
  /// The initial state passed to the constructor, used for [reset] operations.
  final S _initialState;

  /// Creates an [AbstractListCubit] with the given initial state.
  ///
  /// The [initialState] is stored internally to support [reset] functionality
  /// which restores the search model to its original values.
  AbstractListCubit(super.initialState) : _initialState = initialState;

  /// Provides a stream of results for scenarios where [resolveData] fails.
  ///
  /// Override this method to provide fallback data streaming, typically used
  /// for cache-first strategies where cached data is emitted while network
  /// data is being fetched.
  ///
  /// This stream is consumed when [resolveData] throws an exception.
  ///
  /// ```dart
  /// @override
  /// Stream<Result> resolveStreamData() async* {
  ///   yield await _repository.getCachedUsers();
  ///   yield await _repository.getNetworkUsers();
  /// }
  /// ```
  Stream<Result> resolveStreamData() async* {
    throw UnimplementedError();
  }

  /// Fetches data from the data source (e.g., API, database).
  ///
  /// This is the primary method to implement when extending this class.
  /// It should return a [Result] containing the data or error information.
  ///
  /// The current search model can be accessed via `state.searchModel` for
  /// filterable states.
  ///
  /// ```dart
  /// @override
  /// Future<Result> resolveData() async {
  ///   return _repository.getUsers(
  ///     page: state.searchModel.page,
  ///     filters: state.searchModel.filters,
  ///   );
  /// }
  /// ```
  Future<Result> resolveData() async => throw UnimplementedError();

  /// Called before [load] begins fetching data.
  ///
  /// Use this hook to perform setup tasks such as:
  /// - Showing loading indicators
  /// - Canceling previous requests
  /// - Validating search parameters
  ///
  /// The optional [searchModel] parameter contains the new search model
  /// if one was passed to [load].
  Future<void> onBeforeLoad<TSearchModel>([TSearchModel? searchModel]) async {}

  /// Called before [refresh] begins fetching data.
  ///
  /// Use this hook to perform setup tasks specific to refresh operations,
  /// such as resetting scroll position or clearing selection state.
  Future<void> onBeforeRefresh() async {}

  /// Called before [loadMore] begins fetching additional data.
  ///
  /// Use this hook to perform setup tasks for pagination, such as
  /// showing a loading indicator at the bottom of the list.
  Future<void> onBeforeLoadMore() async {}

  /// Called after [load] completes with the fetched result.
  ///
  /// Use this hook to perform post-load tasks such as:
  /// - Hiding loading indicators
  /// - Logging analytics events
  /// - Triggering dependent operations
  ///
  /// The [result] contains the data or error from the load operation.
  Future<void> onAfterLoad(Result result) async {}

  /// Called after [refresh] completes with the fetched result.
  ///
  /// Use this hook to perform post-refresh tasks such as showing
  /// success messages or updating timestamps.
  Future<void> onAfterRefresh(Result result) async {}

  /// Called after [loadMore] completes with the fetched result.
  ///
  /// Use this hook to perform post-pagination tasks such as
  /// hiding the loading indicator or scrolling to new items.
  Future<void> onAfterLoadMore(Result result) async {}

  /// Saves the current search model state for potential reversion.
  ///
  /// Call this method before allowing users to modify filters. If the user
  /// cancels their changes, call [revert] to restore this snapshot.
  ///
  /// The snapshot uses deep copying if the search model implements [CopyWith],
  /// otherwise it stores a reference (which may cause issues with mutable objects).
  ///
  /// ```dart
  /// void onFilterButtonPressed() {
  ///   cubit.snapshot();
  ///   showFilterDialog();
  /// }
  ///
  /// void onFilterDialogCanceled() {
  ///   cubit.revert();
  /// }
  /// ```
  Future<void> snapshot() async {
    _deepCopyToTempSearchModel(true);
  }

  /// Updates the search model and marks the state as dirty.
  ///
  /// Use this method to modify filter values. The changes can be reverted
  /// by calling [revert] if a snapshot was previously taken.
  ///
  /// This method only works if the state extends [AbstractListFilterableState].
  ///
  /// ```dart
  /// cubit.update(searchModel.copyWith(category: 'electronics'));
  /// ```
  Future<void> update<TSearchModel>(TSearchModel searchModel) async {
    if (state is AbstractListFilterableState) {
      (state as AbstractListFilterableState).searchModel = searchModel;
      (state as AbstractListFilterableState).isDirty = true;
      emit(state.copyWith());
    }
  }

  /// Reverts the search model to the last snapshot.
  ///
  /// Call this method to discard changes made since the last [snapshot].
  /// Pagination values are preserved during reversion.
  ///
  /// This is typically used when a user cancels a filter dialog.
  Future<void> revert() async {
    _deepCopyToSearchModel(true);
    if (state is AbstractListFilterableState) {
      (state as AbstractListFilterableState).isDirty = false;
    }
  }

  /// Resets all filters to their initial values and reloads data.
  ///
  /// This restores both the search model and temporary search model to
  /// the values from the initial state passed to the constructor.
  ///
  /// Use this for "Clear all filters" functionality.
  Future<void> reset() async {
    _deepCopyToInitialSearchModel(true);
    if (state is AbstractListFilterableState) {
      (state as AbstractListFilterableState).isDirty = false;
    }
  }

  /// Internal method to save current filters before loading.
  Future<void> _applySnapshot() async {
    _deepCopyToTempSearchModel(true);
    if (state is AbstractListFilterableState) {
      (state as AbstractListFilterableState).isDirty = false;
    }
  }

  /// Loads data from the data source, replacing any existing items.
  ///
  /// This is the primary method for fetching list data. It:
  /// 1. Saves the current search model as a snapshot
  /// 2. Applies the optional [searchModel] if provided
  /// 3. Resets pagination to the first page
  /// 4. Sets the state to loading
  /// 5. Calls [resolveData] to fetch data
  /// 6. Updates the state with the result
  ///
  /// If [resolveData] throws, falls back to [resolveStreamData] for
  /// cache-first strategies.
  ///
  /// ```dart
  /// // Load with current filters
  /// await cubit.load();
  ///
  /// // Load with new filters
  /// await cubit.load(MySearchModel(category: 'books'));
  /// ```
  Future<void> load<TSearchModel>([TSearchModel? searchModel]) async {
    await _applySnapshot();
    _applySearchModelIfPossible(searchModel);
    _resetPaginationIfNeeded();
    await onBeforeLoad(searchModel);
    _updateStateWithStatus(ResultStatus.loading);

    try {
      final result = await resolveData();

      updateState(await convertResultToStateAfterLoad(result));
      await onAfterLoad(result);
    } catch (e) {
      // Fallback to stream data (typically cache-first strategy)
      await for (final result in resolveStreamData()) {
        updateState(await convertResultToStateAfterLoad(result));
        await onAfterLoad(result);
      }
    }
  }

  /// Refreshes data by reloading from the data source.
  ///
  /// Unlike [load], refresh:
  /// - Reverts to the snapshotted search model (discards uncommitted filter changes)
  /// - Resets pagination to the first page
  /// - Does not accept new filter parameters
  ///
  /// Use this for pull-to-refresh functionality.
  Future<void> refresh() async {
    await revert();
    _resetPaginationIfNeeded();
    await onBeforeRefresh();

    try {
      final result = await resolveData();

      updateState(await convertResultToStateAfterRefresh(result));
      await onAfterRefresh(result);
    } catch (e) {
      await for (final result in resolveStreamData()) {
        updateState(await convertResultToStateAfterRefresh(result));
        await onAfterRefresh(result);
      }
    }
  }

  /// Loads the next page of data for paginated lists.
  ///
  /// This method:
  /// 1. Reverts any uncommitted filter changes
  /// 2. Increments the pagination (page number or cursor)
  /// 3. Fetches the next page of data
  /// 4. Appends new items to existing items
  ///
  /// Only works if the state extends [AbstractListFilterablePaginatedState].
  ///
  /// The [hasMoreItems] property on the result indicates if more pages exist.
  Future<void> loadMore() async {
    await revert();

    if (state is AbstractListFilterablePaginatedState) {
      (state as AbstractListFilterablePaginatedState).searchModel.increment();

      await onBeforeLoadMore();

      try {
        final result = await resolveData();

        updateState(await convertResultToStateAfterLoadMore(result));
        await onAfterLoadMore(result);
      } catch (e) {
        await for (final result in resolveStreamData()) {
          updateState(await convertResultToStateAfterLoadMore(result));
          await onAfterLoadMore(result);
        }
      }
    }
  }

  /// Converts the API result to state after a [load] or [refresh] operation.
  ///
  /// This method:
  /// - Updates the result status (loading, loaded, loadedCached, error)
  /// - Replaces the items list with new data
  /// - Tracks cached item counts for hybrid cache/network strategies
  /// - Updates pagination metadata (hasMoreItems, cursors)
  ///
  /// Override this method to customize how results are processed.
  Future<S> convertResultToStateAfterLoad(dynamic result) async {
    state.resultStatus = _getStatusFromResult(result) ?? state.resultStatus;

    if (result.isSuccess) {
      state.result = result.data;

      // Track cached items for cache-first strategies
      if (result is CacheResult) {
        state.result.numberOfCachedItems +=
            state.result.items.abstractBlocListCount;
      } else {
        state.result.numberOfCachedItems = 0;
      }

      // Update pagination metadata
      if (state is AbstractListFilterablePaginatedState) {
        final searchModel =
            (state as AbstractListFilterablePaginatedState).searchModel;

        searchModel.update(state.result);

        if (searchModel is Pagination) {
          state.result.hasMoreItems =
              state.result.items.abstractBlocListCount == searchModel.take;
        }

        if (searchModel is CursorPagination) {
          state.result.hasMoreItems = searchModel.nextCursor.isNotEmpty;
        }
      }
    }

    return state.copyWith();
  }

  /// Converts the API result to state after a [refresh] operation.
  ///
  /// By default, delegates to [convertResultToStateAfterLoad].
  /// Override to customize refresh-specific behavior.
  Future<S> convertResultToStateAfterRefresh(dynamic result) async {
    return await convertResultToStateAfterLoad(result);
  }

  /// Converts the API result to state after a [loadMore] operation.
  ///
  /// This method handles the complex logic of merging new items with existing:
  /// - For cached results: prepends existing items, tracks cached count
  /// - For network results: appends new items to existing, clears cached items
  /// - Updates pagination metadata (hasMoreItems, cursors)
  ///
  /// The merging strategy maintains proper list order for infinite scroll.
  Future<S> convertResultToStateAfterLoadMore(dynamic result) async {
    // Handle cached results - prepend existing items to new cached items
    if (result is CacheResult && result.data is GridResult) {
      final stateItems = state.result.items;

      state.result.map(result.data as GridResult);
      state.result.numberOfCachedItems +=
          state.result.items.abstractBlocListCount;
      state.result.items.insertAll(0, stateItems);

      state.resultStatus = _getStatusFromResult(result) ?? state.resultStatus;
      return state.copyWith();
    }

    // Handle network results - append new items to existing
    if (result is! CacheResult && result.data is GridResult) {
      final stateItems = state.result.items;
      final searchModel =
          (state as AbstractListFilterablePaginatedState).searchModel;
      final gridResult = result.data as GridResult;

      state.result.map(gridResult);
      searchModel.update(gridResult);

      if (searchModel is Pagination) {
        state.result.hasMoreItems =
            gridResult.items.abstractBlocListCount == searchModel.take;
      }

      if (searchModel is CursorPagination) {
        state.result.hasMoreItems = searchModel.nextCursor.isNotEmpty;
      }

      // Remove previously cached items when network data arrives
      if (state.resultStatus == ResultStatus.loadedCached) {
        stateItems.abstractBlocListRemoveLastItems(
          state.result.numberOfCachedItems,
        );
        state.result.numberOfCachedItems = 0;
      }

      state.result.items.insertAll(0, stateItems);
      state.resultStatus = _getStatusFromResult(result) ?? state.resultStatus;
      return state.copyWith();
    }

    state.resultStatus = _getStatusFromResult(result) ?? state.resultStatus;
    return state.copyWith();
  }

  /// Determines the [ResultStatus] based on the result type and content.
  ///
  /// Returns:
  /// - [ResultStatus.error] if the result indicates an error
  /// - [ResultStatus.loadedCached] if the result is from cache
  /// - [ResultStatus.loaded] if the result is from network
  /// - `null` if status should remain unchanged
  ResultStatus? _getStatusFromResult(Result result) => result.isError
      ? ResultStatus.error
      : result.hasData
      ? result is CacheResult
            ? ResultStatus.loadedCached
            : ResultStatus.loaded
      : state.resultStatus == ResultStatus.loading
      ? ResultStatus.loaded
      : null;

  /// Safely emits a new state if the cubit is not closed.
  ///
  /// Use this method instead of direct [emit] calls to prevent
  /// errors when the cubit is disposed during async operations.
  void updateState(S state) {
    if (!isClosed) {
      emit(state);
    }
  }

  /// Updates the result status and emits the new state.
  void _updateStateWithStatus(ResultStatus status) {
    state.resultStatus = status;
    updateState(state.copyWith() as S);
  }

  /// Resets pagination to the first page if the state supports pagination.
  void _resetPaginationIfNeeded() {
    if (state is AbstractListFilterablePaginatedState) {
      (state as AbstractListFilterablePaginatedState).searchModel.reset();
    }
  }

  /// Applies the provided search model to the state if supported.
  void _applySearchModelIfPossible<TSearchModel>([TSearchModel? searchModel]) {
    // Update the search model in the state if it is of type AbstractListFilterableState.
    if (state is AbstractListFilterableState) {
      (state as AbstractListFilterableState).searchModel =
          searchModel ??
          (state as AbstractListFilterableState).searchModel ??
          (_initialState as AbstractListFilterableState).searchModel;
    }
  }

  /// Restores the search model from the temporary snapshot.
  ///
  /// Creates a deep copy if the model implements [CopyWith] to avoid
  /// reference sharing issues. Preserves pagination values during restoration.
  void _deepCopyToSearchModel(bool rebuild) {
    if (state is AbstractListFilterableState &&
        (state as AbstractListFilterableState).tempSearchModel != null) {
      final tempSearchModel =
          (state as AbstractListFilterableState).tempSearchModel;

      // Preserve pagination values before restoring filters
      final (skip, take, cursor) = _getPaginationValuesFromSearchModel();

      // Create deep copy to avoid reference sharing
      if (tempSearchModel is CopyWith) {
        (state as AbstractListFilterableState).searchModel = tempSearchModel
            .copyWith();
      } else {
        (state as AbstractListFilterableState).searchModel = tempSearchModel;
      }

      // Restore pagination values
      _setPaginationValuesToSearchModel(skip, take, cursor);
    }

    if (rebuild) {
      emit(state.copyWith());
    }
  }

  /// Saves the current search model to the temporary snapshot.
  ///
  /// Creates a deep copy if the model implements [CopyWith] to avoid
  /// modifications affecting the snapshot.
  void _deepCopyToTempSearchModel(bool rebuild) {
    if (state is AbstractListFilterableState &&
        (state as AbstractListFilterableState).searchModel != null) {
      final searchModel = (state as AbstractListFilterableState).searchModel;

      // Create deep copy to avoid reference sharing
      if (searchModel is CopyWith) {
        (state as AbstractListFilterableState).tempSearchModel = searchModel
            .copyWith();
      } else {
        (state as AbstractListFilterableState).tempSearchModel = searchModel;
      }
    }

    if (rebuild) {
      emit(state.copyWith());
    }
  }

  /// Resets both search models to the initial state values.
  ///
  /// Optionally reloads data after resetting.
  Future<void> _deepCopyToInitialSearchModel(bool reload) async {
    if (state is AbstractListFilterableState) {
      (state as AbstractListFilterableState).tempSearchModel =
          (_initialState as AbstractListFilterableState).searchModel;
      (state as AbstractListFilterableState).searchModel =
          (_initialState as AbstractListFilterableState).searchModel;
    }

    if (reload) {
      await load();
    }
  }

  /// Extracts current pagination values from the search model.
  ///
  /// Returns a tuple of (skip, take, cursor) for offset-based or cursor-based
  /// pagination respectively.
  (int, int, String) _getPaginationValuesFromSearchModel() {
    if (state is AbstractListFilterablePaginatedState) {
      if ((state as AbstractListFilterablePaginatedState).searchModel
          is Pagination) {
        final pagination =
            (state as AbstractListFilterablePaginatedState).searchModel
                as Pagination;

        return (pagination.skip, pagination.take, '');
      } else if ((state as AbstractListFilterablePaginatedState).searchModel
          is CursorPagination) {
        final cursorPagination =
            (state as AbstractListFilterablePaginatedState).searchModel
                as CursorPagination;

        return (0, 0, cursorPagination.cursor);
      }
    }

    return (0, 0, '');
  }

  /// Restores pagination values to the search model.
  ///
  /// Used after restoring filters from snapshot to maintain pagination position.
  void _setPaginationValuesToSearchModel(int skip, int take, String cursor) {
    if (state is AbstractListFilterablePaginatedState) {
      if ((state as AbstractListFilterablePaginatedState).searchModel
          is Pagination) {
        final pagination =
            (state as AbstractListFilterablePaginatedState).searchModel
                as Pagination;

        pagination.skip = skip;
        pagination.take = take;
      } else if ((state as AbstractListFilterablePaginatedState).searchModel
          is CursorPagination) {
        final cursorPagination =
            (state as AbstractListFilterablePaginatedState).searchModel
                as CursorPagination;

        cursorPagination.cursor = cursor;
      }
    }
  }
}
