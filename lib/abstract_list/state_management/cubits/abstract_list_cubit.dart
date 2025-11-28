import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:abstract_bloc/extensions/_all.dart';
import 'package:abstract_bloc/models/cursor_pagination.dart';
import 'package:flutter/widgets.dart';

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

  /// Saves a snapshot of current search model to temporary search model so it can be reverted if needed
  /// Make sure that your search model implements CopyWith if it's a complex model (class)
  Future<void> snapshot() async {
    _deepCopyToTempSearchModel(true);
  }

  /// Updates search model, it can be reverted to previous state by calling revert
  Future<void> update<TSearchModel>(TSearchModel searchModel) async {
    if (state is AbstractListFilterableState) {
      (state as AbstractListFilterableState).searchModel = searchModel;
      emit(state.copyWith());
    }
  }

  /// Reverts to previous state of search model (if there is tempSearchModel, if previously used snapshot and load occured)
  Future<void> revert() async {
    _deepCopyToSearchModel(true);
  }

  /// Resets all filters, both: search model and temporary search model
  Future<void> reset() async {
    _deepCopyToInitialSearchModel(true);
  }

  /// Method to load data potentially with a search model.
  Future<void> load<TSearchModel>([TSearchModel? searchModel]) async {
    await _applySnapshot();
    _applySearchModelIfPossible();
    _resetPaginationIfNeeded();
    await onBeforeLoad();
    _updateStateWithStatus(ResultStatus.loading);

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

  /// Load more data for paginated lists.
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

  /// Convert results to state after loading data.
  Future<S> convertResultToStateAfterLoad(dynamic result) async {
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

  Future<S> convertResultToStateAfterRefresh(dynamic result) async {
    return await convertResultToStateAfterLoad(result);
  }

  Future<S> convertResultToStateAfterLoadMore(dynamic result) async {
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

  void _updateStateWithStatus(ResultStatus status) {
    state.resultStatus = status;
    updateState(state.copyWith() as S);
  }

  void _resetPaginationIfNeeded() {
    debugPrint('BEFORE CHECKING FILTERABLE PAGINATED STATE');
    if (state is AbstractListFilterablePaginatedState) {
      debugPrint(
        'AFTER CHECKING FILTERABLE PAGINATED STATE: ${(state as AbstractListFilterablePaginatedState).searchModel.toJson()}',
      );
      (state as AbstractListFilterablePaginatedState).searchModel.reset();
      debugPrint(
        'AFTER CHECKING FILTERABLE PAGINATED STATE: ${(state as AbstractListFilterablePaginatedState).searchModel.toJson()}',
      );
    }
  }

  void _applySearchModelIfPossible<TSearchModel>([TSearchModel? searchModel]) {
    // Update the search model in the state if it is of type AbstractListFilterableState.
    if (state is AbstractListFilterableState && searchModel != null) {
      (state as AbstractListFilterableState).searchModel = searchModel;
    }
  }

  Future<void> _applySnapshot() async {
    _deepCopyToTempSearchModel(true);
  }

  void _deepCopyToSearchModel(bool rebuild) {
    if (state is AbstractListFilterableState &&
        (state as AbstractListFilterableState).tempSearchModel != null) {
      if ((state as AbstractListFilterableState).tempSearchModel is CopyWith) {
        (state as AbstractListFilterableState).searchModel =
            ((state as AbstractListFilterableState).tempSearchModel as CopyWith)
                .copyWith();
      } else {
        (state as AbstractListFilterableState).searchModel =
            (state as AbstractListFilterableState).tempSearchModel;
      }
    }

    if (rebuild) {
      emit(state.copyWith());
    }
  }

  void _deepCopyToTempSearchModel(bool rebuild) {
    if (state is AbstractListFilterableState &&
        (state as AbstractListFilterableState).searchModel != null) {
      if ((state as AbstractListFilterableState).searchModel is CopyWith) {
        (state as AbstractListFilterableState).tempSearchModel =
            ((state as AbstractListFilterableState).searchModel as CopyWith)
                .copyWith();
      } else {
        (state as AbstractListFilterableState).tempSearchModel =
            (state as AbstractListFilterableState).searchModel;
      }
    }

    if (rebuild) {
      emit(state.copyWith());
    }
  }

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
}
