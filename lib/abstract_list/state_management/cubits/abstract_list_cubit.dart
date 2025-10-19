import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:abstract_bloc/extensions/_all.dart';
import 'package:abstract_bloc/models/cursor_pagination.dart';

/// An abstract class representing a cubit for managing a list state in a generic manner.
abstract class AbstractListCubit<S extends AbstractListState> extends Cubit<S> {
  final S _initialState;

  /// Constructor that initializes the cubit with its initial state.
  AbstractListCubit(super.initialState) : _initialState = initialState;

  /// This method must be implemented to yield stream data.
  Stream<Result> resolveStreamData() async* {
    throw UnimplementedError();
  }

  /// This method must be implemented to resolve data asynchronously.
  Future<Result> resolveData() async => throw UnimplementedError();

  /// Hook to manage tasks before loading data.
  Future<void> onBeforeLoad<TSearchModel>([TSearchModel? searchModel]) async {}

  /// Hook to manage tasks before refreshing data.
  Future<void> onBeforeRefresh() async {}

  /// Hook to manage tasks before loading more data.
  Future<void> onBeforeLoadMore() async {}

  /// Hook to manage tasks after data is loaded.
  Future<void> onAfterLoad(Result result) async {}

  /// Hook to manage tasks after data is refreshed.
  Future<void> onAfterRefresh(Result result) async {}

  /// Hook to manage tasks after more data is loaded.
  Future<void> onAfterLoadMore(Result result) async {}

  /// Method to load data potentially with a search model.
  Future<void> load<TSearchModel>([TSearchModel? searchModel]) async {
    // Update the search model in the state if it is of type AbstractListFilterableState.
    if (state is AbstractListFilterableState) {
      (state as AbstractListFilterableState).searchModel = searchModel ??
          (_initialState as AbstractListFilterableState).searchModel;
    }

    if (state is AbstractListFilterablePaginatedState) {
      (state as AbstractListFilterablePaginatedState).searchModel.reset();
    }

    await onBeforeLoad();

    state.resultStatus = ResultStatus.loading;
    updateState(state.copyWith() as S);

    try {
      final result = await resolveData();

      updateState(await convertResultToStateAfterLoad(result));
      await onAfterLoad(result);
    } catch (e) {
      // Handle errors by streaming data
      await for (final result in resolveStreamData()) {
        updateState(await convertResultToStateAfterLoad(result));
        await onAfterLoad(result);
      }
    }
  }

  /// Refresh the current data and reset the state.
  Future<void> refresh() async {
    if (state is AbstractListFilterablePaginatedState) {
      (state as AbstractListFilterablePaginatedState).searchModel.reset();
    }

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

  /// Load more data for paginated lists.
  Future<void> loadMore() async {
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

  /// Convert results to state after loading data.
  Future<S> convertResultToStateAfterLoad(result) async {
    state.resultStatus = _getStatusFromResult(result) ?? state.resultStatus;

    if (result.isSuccess) {
      state.result = result.data;

      // Manage cached items
      if (result is CacheResult) {
        state.result.numberOfCachedItems +=
            state.result.items.abstractBlocListCount;
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

    return state.copyWith();
  }

  // Helper methods to convert results after refresh and load more

  Future<S> convertResultToStateAfterRefresh(result) async {
    return await convertResultToStateAfterLoad(result);
  }

  Future<S> convertResultToStateAfterLoadMore(result) async {
    // Logic for handling cached and network responses while loading more items
    if (result is CacheResult && result.data is GridResult) {
      final stateItems = state.result.items;

      state.result.map(result.data as GridResult);
      state.result.numberOfCachedItems +=
          state.result.items.abstractBlocListCount;
      state.result.items.insertAll(0, stateItems);

      state.resultStatus = _getStatusFromResult(result) ?? state.resultStatus;
      return state.copyWith();
    }

    // Handle network result similarly
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

      if (state.resultStatus == ResultStatus.loadedCached) {
        stateItems
            .abstractBlocListRemoveLastItems(state.result.numberOfCachedItems);
        state.result.numberOfCachedItems = 0;
      }

      state.result.items.insertAll(0, stateItems);
      state.resultStatus = _getStatusFromResult(result) ?? state.resultStatus;
      return state.copyWith();
    }

    state.resultStatus = _getStatusFromResult(result) ?? state.resultStatus;
    return state.copyWith();
  }

  /// Helper method to determine the status from the result.
  ResultStatus? _getStatusFromResult(Result result) => result.isError
      ? ResultStatus.error
      : result.hasData
          ? result is CacheResult
              ? ResultStatus.loadedCached
              : ResultStatus.loaded
          : state.resultStatus == ResultStatus.loading
              ? ResultStatus.loaded
              : null;

  /// Emit a new state, ensuring the cubit isn't closed.
  void updateState(S state) {
    if (!isClosed) {
      emit(state);
    }
  }
}
