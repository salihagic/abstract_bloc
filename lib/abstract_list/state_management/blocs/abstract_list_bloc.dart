import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:abstract_bloc/extensions/_all.dart';
import 'package:abstract_bloc/models/cursor_pagination.dart';

/// An abstract Bloc for managing list-based state using the event-driven pattern.
///
/// This class provides a complete solution for managing lists of data with:
/// - Initial load, refresh, and load-more (pagination) operations
/// - Support for both network and cached data sources
/// - Event-driven architecture for better separation of concerns
/// - Lifecycle hooks for customization
///
/// ## Usage
///
/// Extend this class and implement [resolveData] to fetch your data:
///
/// ```dart
/// class UsersBloc extends AbstractListBloc<UsersState> {
///   final UsersRepository _repository;
///
///   UsersBloc(this._repository) : super(UsersState.initial());
///
///   @override
///   AbstractListState initialState() => UsersState.initial();
///
///   @override
///   Future<Result> resolveData() async {
///     return _repository.getUsers(state.searchModel);
///   }
/// }
/// ```
///
/// ## Dispatching Events
///
/// Use events to trigger state changes:
///
/// ```dart
/// // Load data
/// bloc.add(AbstractListLoadEvent());
///
/// // Load with search model
/// bloc.add(AbstractListLoadEvent(searchModel: mySearchModel));
///
/// // Refresh data
/// bloc.add(AbstractListRefreshEvent());
///
/// // Load more (pagination)
/// bloc.add(AbstractListLoadMoreEvent());
/// ```
///
/// ## State Requirements
///
/// The state type [S] must extend [AbstractListState]. For filtering support,
/// use [AbstractListFilterableState]. For pagination, use
/// [AbstractListFilterablePaginatedState].
///
/// ## Bloc vs Cubit
///
/// Use [AbstractListBloc] when you need:
/// - Event-driven architecture with explicit event types
/// - Better separation between UI and business logic
/// - Event transformation capabilities (debounce, throttle, etc.)
///
/// Use [AbstractListCubit] when you need:
/// - Simpler API with direct method calls
/// - Filter snapshot/revert functionality
/// - Less boilerplate code
abstract class AbstractListBloc<S extends AbstractListState>
    extends Bloc<AbstractListEvent, S> {
  /// Creates an [AbstractListBloc] with the given initial state.
  ///
  /// Automatically registers event handlers for:
  /// - [AbstractListLoadEvent] → [load]
  /// - [AbstractListRefreshEvent] → [refresh]
  /// - [AbstractListLoadMoreEvent] → [loadMore]
  AbstractListBloc(super.initialState) {
    on((AbstractListEvent event, Emitter<S> emit) async {
      if (event is AbstractListLoadEvent) {
        await load(event, emit);
      } else if (event is AbstractListRefreshEvent) {
        await refresh(event, emit);
      } else if (event is AbstractListLoadMoreEvent) {
        await loadMore(event, emit);
      }
    });
  }

  /// Returns a fresh instance of the initial state.
  ///
  /// This is used to reset the search model when loading new data.
  /// Must be implemented by subclasses to provide the default state.
  ///
  /// ```dart
  /// @override
  /// AbstractListState initialState() => UsersState(
  ///   resultStatus: ResultStatus.loading,
  ///   result: GridResult<User>(),
  ///   searchModel: UserSearchModel(),
  /// );
  /// ```
  AbstractListState initialState();

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
  /// - Modifying the search model based on the event
  ///
  /// Parameters:
  /// - [event]: The load event that triggered this operation
  /// - [emit]: The emitter to emit intermediate states if needed
  Future<void> onBeforeLoad(dynamic event, Emitter<S> emit) async {}

  /// Called before [refresh] begins fetching data.
  ///
  /// Use this hook to perform setup tasks specific to refresh operations,
  /// such as resetting scroll position or clearing selection state.
  ///
  /// Parameters:
  /// - [event]: The refresh event that triggered this operation
  /// - [emit]: The emitter to emit intermediate states if needed
  Future<void> onBeforeRefresh(dynamic event, Emitter<S> emit) async {}

  /// Called before [loadMore] begins fetching additional data.
  ///
  /// Use this hook to perform setup tasks for pagination, such as
  /// showing a loading indicator at the bottom of the list.
  ///
  /// Parameters:
  /// - [event]: The load more event that triggered this operation
  /// - [emit]: The emitter to emit intermediate states if needed
  Future<void> onBeforeLoadMore(dynamic event, Emitter<S> emit) async {}

  /// Called after [load] completes with the fetched result.
  ///
  /// Use this hook to perform post-load tasks such as:
  /// - Hiding loading indicators
  /// - Logging analytics events
  /// - Triggering dependent operations
  ///
  /// Parameters:
  /// - [event]: The load event that triggered this operation
  /// - [emit]: The emitter to emit additional states if needed
  /// - [result]: The result from the data fetch operation
  Future<void> onAfterLoad(
    dynamic event,
    Emitter<S> emit,
    Result result,
  ) async {}

  /// Called after [refresh] completes with the fetched result.
  ///
  /// Use this hook to perform post-refresh tasks such as showing
  /// success messages or updating timestamps.
  ///
  /// Parameters:
  /// - [event]: The refresh event that triggered this operation
  /// - [emit]: The emitter to emit additional states if needed
  /// - [result]: The result from the data fetch operation
  Future<void> onAfterRefresh(
    dynamic event,
    Emitter<S> emit,
    Result result,
  ) async {}

  /// Called after [loadMore] completes with the fetched result.
  ///
  /// Use this hook to perform post-pagination tasks such as
  /// hiding the loading indicator or scrolling to new items.
  ///
  /// Parameters:
  /// - [event]: The load more event that triggered this operation
  /// - [emit]: The emitter to emit additional states if needed
  /// - [result]: The result from the data fetch operation
  Future<void> onAfterLoadMore(
    dynamic event,
    Emitter<S> emit,
    Result result,
  ) async {}

  /// Handles the [AbstractListLoadEvent] to load data.
  ///
  /// This method:
  /// 1. Sets the search model from the event or uses the initial state's model
  /// 2. Sets the state to loading
  /// 3. Calls [resolveData] to fetch data
  /// 4. Updates the state with the result
  ///
  /// If [resolveData] throws, falls back to [resolveStreamData] for
  /// cache-first strategies.
  ///
  /// Parameters:
  /// - [event]: Contains optional searchModel to filter the data
  /// - [emit]: The emitter to emit state changes
  Future<void> load(AbstractListLoadEvent event, Emitter<S> emit) async {
    // Apply search model from event or use initial state's model
    if (state is AbstractListFilterableState) {
      (state as AbstractListFilterableState).searchModel =
          event.searchModel ??
          (initialState() as AbstractListFilterableState).searchModel;
    }

    await onBeforeLoad(event, emit);

    state.resultStatus = ResultStatus.loading;
    updateState(state.copyWith() as S, emit);

    try {
      updateState(
        await convertResultToStateAfterLoad(await resolveData()),
        emit,
      );
    } catch (e) {
      // Fallback to stream data (typically cache-first strategy)
      await for (final result in resolveStreamData()) {
        updateState(await convertResultToStateAfterLoad(result), emit);
        await onAfterLoad(event, emit, result);
      }
    }
  }

  /// Handles the [AbstractListRefreshEvent] to refresh data.
  ///
  /// This method:
  /// 1. Resets pagination to the first page
  /// 2. Fetches fresh data from the source
  /// 3. Replaces existing items with new data
  ///
  /// Use this for pull-to-refresh functionality.
  ///
  /// Parameters:
  /// - [event]: The refresh event
  /// - [emit]: The emitter to emit state changes
  Future<void> refresh(AbstractListRefreshEvent event, Emitter<S> emit) async {
    // Reset pagination to first page
    if (state is AbstractListFilterablePaginatedState) {
      (state as AbstractListFilterablePaginatedState).searchModel.reset();
    }

    await onBeforeRefresh(event, emit);

    try {
      updateState(
        await convertResultToStateAfterRefresh(await resolveData()),
        emit,
      );
    } catch (e) {
      await for (final result in resolveStreamData()) {
        updateState(await convertResultToStateAfterRefresh(result), emit);
        await onAfterRefresh(event, emit, result);
      }
    }
  }

  /// Handles the [AbstractListLoadMoreEvent] to load additional pages.
  ///
  /// This method:
  /// 1. Increments the pagination (page number or cursor)
  /// 2. Fetches the next page of data
  /// 3. Appends new items to existing items
  ///
  /// Only works if the state extends [AbstractListFilterablePaginatedState].
  ///
  /// Parameters:
  /// - [event]: The load more event
  /// - [emit]: The emitter to emit state changes
  Future<void> loadMore(
    AbstractListLoadMoreEvent event,
    Emitter<S> emit,
  ) async {
    if (state is AbstractListFilterablePaginatedState) {
      // Increment page/cursor for next batch
      (state as AbstractListFilterablePaginatedState).searchModel.increment();

      await onBeforeLoadMore(event, emit);

      try {
        updateState(
          await convertResultToStateAfterLoadMore(await resolveData()),
          emit,
        );
      } catch (e) {
        await for (final result in resolveStreamData()) {
          updateState(await convertResultToStateAfterLoadMore(result), emit);
          await onAfterLoadMore(event, emit, result);
        }
      }
    }
  }

  /// Converts the API result to state after a [load] operation.
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
    if (result is CacheResult &&
        result.data != null &&
        result.data is GridResult) {
      final stateItems = state.result.items;

      state.result.map(result.data as GridResult);
      state.result.numberOfCachedItems +=
          state.result.items.abstractBlocListCount;
      state.result.items.insertAll(0, stateItems);

      state.resultStatus = _getStatusFromResult(result) ?? state.resultStatus;

      return state.copyWith();
    }

    // Handle network results - append new items to existing
    if (result is! CacheResult &&
        result.data != null &&
        result.data is GridResult) {
      final stateItems = state.result.items;

      state.result.map(result.data as GridResult);

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

  /// Safely emits a new state if the bloc is not closed.
  ///
  /// Use this method instead of direct [emit] calls to prevent
  /// errors when the bloc is disposed during async operations.
  ///
  /// Parameters:
  /// - [state]: The new state to emit
  /// - [emit]: The emitter from the event handler
  void updateState(S state, Emitter<S> emit) {
    if (!isClosed) {
      emit(state);
    }
  }
}
