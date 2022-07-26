import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:abstract_bloc/extensions/_all.dart';

abstract class AbstractListBloc<S extends AbstractListState>
    extends Bloc<AbstractListEvent, S> {
  AbstractListBloc(S initialState) : super(initialState) {
    on(
      (AbstractListEvent event, Emitter<S> emit) async {
        if (event is AbstractListLoadEvent) {
          await load(event, emit);
        } else if (event is AbstractListRefreshEvent) {
          await refresh(event, emit);
        } else if (event is AbstractListLoadMoreEvent) {
          await loadMore(event, emit);
        }
      },
    );
  }

  AbstractListState initialState();

  Stream<Result> resolveStreamData() async* {
    throw UnimplementedError();
  }

  Future<Result> resolveData() async => throw UnimplementedError();

  Future<void> onBeforeLoad(event, Emitter<S> emit) async {}

  Future<void> onBeforeRefresh(event, Emitter<S> emit) async {}

  Future<void> onBeforeLoadMore(event, Emitter<S> emit) async {}

  Future<void> onAfterLoad(event, Emitter<S> emit, Result result) async {}

  Future<void> onAfterRefresh(event, Emitter<S> emit, Result result) async {}

  Future<void> onAfterLoadMore(event, Emitter<S> emit, Result result) async {}

  Future<void> load(AbstractListLoadEvent event, Emitter<S> emit) async {
    if (state is AbstractListFilterableState) {
      (state as AbstractListFilterableState).searchModel = event.searchModel ??
          (initialState() as AbstractListFilterableState).searchModel;
    }

    await onBeforeLoad(event, emit);

    state.resultStatus = ResultStatus.loading;
    emit(state.copyWith() as S);

    try {
      emit(await convertResultToStateAfterLoad(await resolveData()));
    } catch (e) {
      await for (final result in resolveStreamData()) {
        emit(await convertResultToStateAfterLoad(result));
        await onAfterLoad(event, emit, result);
      }
    }
  }

  Future<void> refresh(AbstractListRefreshEvent event, Emitter<S> emit) async {
    if (state is AbstractListFilterablePaginatedState) {
      (state as AbstractListFilterablePaginatedState).searchModel.reset();
    }

    await onBeforeRefresh(event, emit);

    try {
      emit(await convertResultToStateAfterRefresh(await resolveData()));
    } catch (e) {
      await for (final result in resolveStreamData()) {
        emit(await convertResultToStateAfterRefresh(result));
        await onAfterRefresh(event, emit, result);
      }
    }
  }

  Future<void> loadMore(
      AbstractListLoadMoreEvent event, Emitter<S> emit) async {
    if (state is AbstractListFilterablePaginatedState) {
      (state as AbstractListFilterablePaginatedState).searchModel.increment();

      await onBeforeLoadMore(event, emit);

      try {
        emit(await convertResultToStateAfterLoadMore(await resolveData()));
      } catch (e) {
        await for (final result in resolveStreamData()) {
          emit(await convertResultToStateAfterLoadMore(result));
          await onAfterLoadMore(event, emit, result);
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
}
