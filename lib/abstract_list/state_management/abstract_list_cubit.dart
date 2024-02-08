import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:abstract_bloc/extensions/_all.dart';

abstract class AbstractListCubit<S extends AbstractListState> extends Cubit<S> {
  AbstractListCubit(S initialState) : super(initialState);

  AbstractListState initialState();

  Stream<Result> resolveStreamData() async* {
    throw UnimplementedError();
  }

  Future<Result> resolveData() async => throw UnimplementedError();

  Future<void> onBeforeLoad<TSearchModel>([TSearchModel? searchModel]) async {}

  Future<void> onBeforeRefresh() async {}

  Future<void> onBeforeLoadMore() async {}

  Future<void> onAfterLoad(Result result) async {}

  Future<void> onAfterRefresh(Result result) async {}

  Future<void> onAfterLoadMore(Result result) async {}

  Future<void> load<TSearchModel>([TSearchModel? searchModel]) async {
    if (state is AbstractListFilterableState) {
      (state as AbstractListFilterableState).searchModel = searchModel ??
          (initialState() as AbstractListFilterableState).searchModel;
    }

    await onBeforeLoad();

    state.resultStatus = ResultStatus.loading;
    updateState(state.copyWith() as S);

    try {
      updateState(await convertResultToStateAfterLoad(await resolveData()));
    } catch (e) {
      await for (final result in resolveStreamData()) {
        updateState(await convertResultToStateAfterLoad(result));
        await onAfterLoad(result);
      }
    }
  }

  Future<void> refresh() async {
    if (state is AbstractListFilterablePaginatedState) {
      (state as AbstractListFilterablePaginatedState).searchModel.reset();
    }

    await onBeforeRefresh();

    try {
      updateState(await convertResultToStateAfterRefresh(await resolveData()));
    } catch (e) {
      await for (final result in resolveStreamData()) {
        updateState(await convertResultToStateAfterRefresh(result));
        await onAfterRefresh(result);
      }
    }
  }

  Future<void> loadMore() async {
    if (state is AbstractListFilterablePaginatedState) {
      (state as AbstractListFilterablePaginatedState).searchModel.increment();

      await onBeforeLoadMore();

      try {
        updateState(
            await convertResultToStateAfterLoadMore(await resolveData()));
      } catch (e) {
        await for (final result in resolveStreamData()) {
          updateState(await convertResultToStateAfterLoadMore(result));
          await onAfterLoadMore(result);
        }
      }
    }
  }

  Future<S> convertResultToStateAfterLoad(result) async {
    state.resultStatus = _getStatusFromResult(result) ?? state.resultStatus;

    if (result.isSuccess) {
      state.result = result.data;

      if (result is CacheResult) {
        state.result.numberOfCachedItems += state.result.items.count;
      } else {
        state.result.numberOfCachedItems = 0;
      }

      if (state is AbstractListFilterablePaginatedState) {
        state.result.hasMoreItems = state.result.items.count ==
            (state as AbstractListFilterablePaginatedState).searchModel.take;
      }
    }

    return state.copyWith();
  }

  Future<S> convertResultToStateAfterRefresh(result) async {
    return await convertResultToStateAfterLoad(result);
  }

  Future<S> convertResultToStateAfterLoadMore(result) async {
    // Cached with data
    if (result is CacheResult &&
        result.data != null &&
        result.data is GridResult) {
      final stateItems = state.result.items;

      state.result.map(result.data as GridResult);

      state.result.numberOfCachedItems += state.result.items.count;

      state.result.items.insertAll(0, stateItems);

      state.resultStatus = _getStatusFromResult(result) ?? state.resultStatus;

      return state.copyWith();
    }

    // Network
    if (result is! CacheResult &&
        result.data != null &&
        result.data is GridResult) {
      final stateItems = state.result.items;

      state.result.map(result.data as GridResult);

      if (state.resultStatus == ResultStatus.loadedCached) {
        stateItems.removeLastItems(state.result.numberOfCachedItems);
        state.result.numberOfCachedItems = 0;
      }

      state.result.items.insertAll(0, stateItems);

      state.resultStatus = _getStatusFromResult(result) ?? state.resultStatus;

      return state.copyWith();
    }

    state.resultStatus = _getStatusFromResult(result) ?? state.resultStatus;

    return state.copyWith();
  }

  ResultStatus? _getStatusFromResult(Result result) => result.isError
      ? ResultStatus.error
      : result.hasData
          ? result is CacheResult
              ? ResultStatus.loadedCached
              : ResultStatus.loaded
          : state.resultStatus == ResultStatus.loading
              ? ResultStatus.loaded
              : null;

  void updateState(S state) {
    if (!isClosed) {
      emit(state);
    }
  }
}
