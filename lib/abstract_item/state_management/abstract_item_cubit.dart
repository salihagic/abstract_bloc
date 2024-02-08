import 'package:abstract_bloc/abstract_bloc.dart';

abstract class AbstractItemCubit<S extends AbstractItemState> extends Cubit<S> {
  AbstractItemCubit(S initialState) : super(initialState);

  Future<Result> resolveData() async => throw UnimplementedError();

  Stream<Result> resolveStreamData() async* {
    throw UnimplementedError();
  }

  Future<void> onBeforeLoad<TSearchModel>(TSearchModel? searchModel) async {}

  Future<void> load<TSearchModel>([TSearchModel? searchModel]) async {
    final previousState = state.copyWith();

    if (state is AbstractItemFilterableState) {
      (state as AbstractItemFilterableState).searchModel =
          searchModel ?? (state as AbstractItemFilterableState).searchModel;
    }

    await onBeforeLoad(searchModel);

    state.resultStatus = ResultStatus.loading;
    updateState(state.copyWith() as S);

    try {
      updateState(convertResultToState(await resolveData()));
    } catch (e) {
      await for (final result in resolveStreamData()) {
        updateState(convertResultToState(result));
      }
    }

    await onAfterLoad(searchModel, previousState);
  }

  Future<void> onAfterLoad<TSearchModel>(
      TSearchModel? searchModel, S previousState) async {}

  S convertResultToState(Result result) {
    state.resultStatus = _getStatusFromResult(result) ?? state.resultStatus;

    if (result.isSuccess) {
      state.item = result.data;
    }

    return state.copyWith();
  }

  ResultStatus? _getStatusFromResult(Result result) => result.isError
      ? ResultStatus.error
      : result.hasData && result is CacheResult
          ? ResultStatus.loadedCached
          : ResultStatus.loaded;

  void updateState(S state) {
    if (!isClosed) {
      emit(state);
    }
  }
}
