import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:abstract_bloc/extensions/_all.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rest_api_client/rest_api_client.dart';

abstract class AbstractListBloc<E extends AbstractListEvent,
    S extends AbstractListState> extends Bloc<E, S> {
  AbstractListBloc(S initialState) : super(initialState) {
    on(
      (AbstractListEvent event, Emitter<S> emit) async {
        if (event is AbstractListLoadEvent) {
          await _load(event, emit);
        } else if (event is AbstractListRefreshEvent) {
          await _refresh(event, emit);
        } else if (event is AbstractListLoadMoreEvent) {
          await _loadMore(event, emit);
        }
      },
    );
  }

  Future<void> onBeforeLoad(event, Emitter<S> emit) async {}

  Stream<Result> resolveStreamData() async* {
    throw UnimplementedError();
  }

  AbstractListState initialState();

  Future<Result> resolveData() async => throw UnimplementedError();

  S convertResultToStateAfterLoadAndRefresh(result) {
    final wasCached = state.resultStatus == ResultStatus.loadedCached;
    state.resultStatus = _getStatusFromResult(result) ?? state.resultStatus;

    if (result.data != null) {
      state.items = result.data;
    } else {
      if (!wasCached) {
        state.items.clear();
      }
    }

    state.cachedItems.clear();
    if (result is CacheResult && result.hasData) {
      state.cachedItems.addAll(result.data);
    }

    _recalculateItems(result);

    return state.copyWith();
  }

  S convertResultToStateAfterLoadMore(result) {
    // Cached with data
    if (result is CacheResult && result.hasData) {
      state.items.addAll(result.data!);
      state.cachedItems.addAll(result.data);
      state.resultStatus = ResultStatus.loadedCached;

      return state.copyWith();
    }

    _recalculateItems(result);

    //Network without data
    if (result is NetworkResult && !result.hasData) {
      if (state is AbstractListFilterablePaginatedState) {
        (state as AbstractListFilterablePaginatedState).searchModel.decrement();

        if (state.resultStatus == ResultStatus.loadedCached) {
          state.items.removeLastItems(state.cachedItems.count);
          state.cachedItems.clear();
        }

        if (state.resultStatus != ResultStatus.loadedCached) {
          state.resultStatus = ResultStatus.loaded;
        }
      }
    }

    //Network with data
    if (result is NetworkResult && result.hasData) {
      if (state.resultStatus == ResultStatus.loadedCached) {
        state.items.removeLastItems(state.cachedItems.count);
        state.cachedItems.clear();
      }

      state.items.addAll(result.data!);
      state.resultStatus = ResultStatus.loaded;

      return state.copyWith();
    }

    return state.copyWith();
  }

  void _recalculateItems(Result result) {
    if (result is NetworkResult &&
        state is AbstractListFilterablePaginatedState) {
      (state as AbstractListFilterablePaginatedState).hasMoreData =
          ((result.data ?? []) as List).count >=
              (state as AbstractListFilterablePaginatedState).searchModel.take;
    }
  }

  Future<void> _load(AbstractListLoadEvent event, Emitter<S> emit) async {
    if (state is AbstractListFilterableState) {
      (state as AbstractListFilterableState).searchModel = event.searchModel ??
          (initialState() as AbstractListFilterableState).searchModel;
    }
    if (state is AbstractListFilterablePaginatedState) {
      (state as AbstractListFilterablePaginatedState).searchModel.reset();
    }

    await onBeforeLoad(event, emit);

    state.resultStatus = ResultStatus.loading;
    emit(state.copyWith() as S);

    try {
      emit(convertResultToStateAfterLoadAndRefresh(await resolveData()));
    } catch (e) {
      await emit.forEach<Result>(
        resolveStreamData(),
        onData: (result) => convertResultToStateAfterLoadAndRefresh(result),
      );
    }
  }

  Future<void> _refresh(AbstractListRefreshEvent event, Emitter<S> emit) async {
    if (state is AbstractListFilterableState) {
      if (state is AbstractListFilterablePaginatedState) {
        (state as AbstractListFilterablePaginatedState).searchModel.reset();
      }

      try {
        emit(convertResultToStateAfterLoadAndRefresh(await resolveData()));
      } catch (e) {
        await emit.forEach<Result>(
          resolveStreamData(),
          onData: (result) => convertResultToStateAfterLoadAndRefresh(result),
        );
      }
    }
  }

  Future<void> _loadMore(
      AbstractListLoadMoreEvent event, Emitter<S> emit) async {
    if (state is AbstractListFilterableState) {
      if (state is AbstractListFilterablePaginatedState) {
        (state as AbstractListFilterablePaginatedState).searchModel.increment();
      }

      try {
        emit(convertResultToStateAfterLoadMore(await resolveData()));
      } catch (e) {
        await emit.forEach<Result>(
          resolveStreamData(),
          onData: (result) => convertResultToStateAfterLoadMore(result),
        );
      }
    }
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
