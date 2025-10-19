import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:abstract_bloc/extensions/_all.dart';
import 'package:abstract_bloc/models/cursor_pagination.dart';

/// An abstract bloc class for handling a list of items with various states.
abstract class AbstractListBloc<S extends AbstractListState>
    extends Bloc<AbstractListEvent, S> {
  /// Constructor initializes the bloc with the given initial state.
  AbstractListBloc(super.initialState) {
    // Handle incoming events
    on(
      (AbstractListEvent event, Emitter<S> emit) async {
        if (event is AbstractListLoadEvent) {
          await load(event, emit); // Load initial data
        } else if (event is AbstractListRefreshEvent) {
          await refresh(event, emit); // Refresh existing data
        } else if (event is AbstractListLoadMoreEvent) {
          await loadMore(event, emit); // Load additional items
        }
      },
    );
  }

  /// Returns the initial state of the list.
  AbstractListState initialState();

  /// Resolves the stream of data to be processed.
  Stream<Result> resolveStreamData() async* {
    throw UnimplementedError(); // Must be implemented in subclasses
  }

  /// Resolves data from source (e.g., API).
  Future<Result> resolveData() async =>
      throw UnimplementedError(); // Must be implemented

  /// Additional operations to perform before loading data.
  Future<void> onBeforeLoad(event, Emitter<S> emit) async {}

  /// Additional operations to perform before refreshing data.
  Future<void> onBeforeRefresh(event, Emitter<S> emit) async {}

  /// Additional operations to perform before loading more data.
  Future<void> onBeforeLoadMore(event, Emitter<S> emit) async {}

  /// Additional operations to perform after loading data.
  Future<void> onAfterLoad(event, Emitter<S> emit, Result result) async {}

  /// Additional operations to perform after refreshing data.
  Future<void> onAfterRefresh(event, Emitter<S> emit, Result result) async {}

  /// Additional operations to perform after loading more data.
  Future<void> onAfterLoadMore(event, Emitter<S> emit, Result result) async {}

  /// Handles loading data when requested.
  Future<void> load(AbstractListLoadEvent event, Emitter<S> emit) async {
    // Set search model if the state supports filtering
    if (state is AbstractListFilterableState) {
      (state as AbstractListFilterableState).searchModel = event.searchModel ??
          (initialState() as AbstractListFilterableState).searchModel;
    }

    await onBeforeLoad(event, emit); // Pre-load actions

    // Set state to loading
    state.resultStatus = ResultStatus.loading;
    updateState(state.copyWith() as S, emit); // Update the state

    try {
      // Attempt to resolve and update state with data
      updateState(
          await convertResultToStateAfterLoad(await resolveData()), emit);
    } catch (e) {
      // Handle loading errors and stream results
      await for (final result in resolveStreamData()) {
        updateState(await convertResultToStateAfterLoad(result), emit);
        await onAfterLoad(event, emit, result);
      }
    }
  }

  /// Handles refreshing the data.
  Future<void> refresh(AbstractListRefreshEvent event, Emitter<S> emit) async {
    // Reset the search model for filterable paginated states
    if (state is AbstractListFilterablePaginatedState) {
      (state as AbstractListFilterablePaginatedState).searchModel.reset();
    }

    await onBeforeRefresh(event, emit); // Pre-refresh actions

    try {
      // Attempt to resolve and update state with refreshed data
      updateState(
          await convertResultToStateAfterRefresh(await resolveData()), emit);
    } catch (e) {
      // Handle refreshing errors and stream results
      await for (final result in resolveStreamData()) {
        updateState(await convertResultToStateAfterRefresh(result), emit);
        await onAfterRefresh(event, emit, result);
      }
    }
  }

  /// Handles loading more data.
  Future<void> loadMore(
      AbstractListLoadMoreEvent event, Emitter<S> emit) async {
    // Increment search model if the state supports pagination
    if (state is AbstractListFilterablePaginatedState) {
      (state as AbstractListFilterablePaginatedState).searchModel.increment();

      await onBeforeLoadMore(event, emit); // Pre-load more actions

      try {
        // Attempt to resolve and update state with more data
        updateState(
            await convertResultToStateAfterLoadMore(await resolveData()), emit);
      } catch (e) {
        // Handle load more errors and stream results
        await for (final result in resolveStreamData()) {
          updateState(await convertResultToStateAfterLoadMore(result), emit);
          await onAfterLoadMore(event, emit, result);
        }
      }
    }
  }

  /// Converts the result after loading data into a new state.
  Future<S> convertResultToStateAfterLoad(result) async {
    state.resultStatus = _getStatusFromResult(result) ?? state.resultStatus;

    if (result.isSuccess) {
      state.result = result.data;

      if (result is CacheResult) {
        state.result.numberOfCachedItems +=
            state.result.items.abstractBlocListCount; // Update cached items
      } else {
        state.result.numberOfCachedItems = 0;
      }

      // If paginated, check if more items are to load
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

    return state.copyWith(); // Return updated state
  }

  /// Converts result after refresh into a new state.
  Future<S> convertResultToStateAfterRefresh(result) async {
    return await convertResultToStateAfterLoad(result); // Reuse load conversion
  }

  /// Converts result after loading more data into a new state.
  Future<S> convertResultToStateAfterLoadMore(result) async {
    // Handle cached data
    if (result is CacheResult &&
        result.data != null &&
        result.data is GridResult) {
      final stateItems = state.result.items;

      state.result
          .map(result.data as GridResult); // Update the state with new results

      state.result.numberOfCachedItems +=
          state.result.items.abstractBlocListCount; // Update cached items

      state.result.items.insertAll(0, stateItems); // Merge items

      state.resultStatus = _getStatusFromResult(result) ?? state.resultStatus;

      return state.copyWith();
    }

    // Handle network results
    if (result is! CacheResult &&
        result.data != null &&
        result.data is GridResult) {
      final stateItems = state.result.items;

      state.result
          .map(result.data as GridResult); // Update with new grid results

      if (state.resultStatus == ResultStatus.loadedCached) {
        stateItems.abstractBlocListRemoveLastItems(
            state.result.numberOfCachedItems); // Clear cached items
        state.result.numberOfCachedItems = 0;
      }

      state.result.items.insertAll(0, stateItems); // Merge items

      state.resultStatus = _getStatusFromResult(result) ?? state.resultStatus;

      return state.copyWith();
    }

    state.resultStatus = _getStatusFromResult(result) ?? state.resultStatus;

    return state.copyWith();
  }

  /// Determine the result status based on the loaded result.
  ResultStatus? _getStatusFromResult(Result result) => result.isError
      ? ResultStatus.error
      : result.hasData
          ? result is CacheResult
              ? ResultStatus.loadedCached
              : ResultStatus.loaded
          : state.resultStatus == ResultStatus.loading
              ? ResultStatus.loaded
              : null;

  /// Updates the current state and emits it if the bloc is not closed.
  void updateState(S state, Emitter<S> emit) {
    if (!isClosed) {
      emit(state);
    }
  }
}
