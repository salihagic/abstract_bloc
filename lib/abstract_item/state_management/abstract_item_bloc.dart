import 'package:abstract_bloc/abstract_bloc.dart';

abstract class AbstractItemBloc<S extends AbstractItemState>
    extends Bloc<AbstractItemEvent, S> {
  AbstractItemBloc(S initialState) : super(initialState) {
    on(
      (AbstractItemEvent event, Emitter<S> emit) async {
        if (event is AbstractItemLoadEvent) {
          await load(event, emit);
        }
      },
    );
  }

  Future<void> onBeforeLoad(
      AbstractItemLoadEvent event, Emitter<S> emit) async {}

  Future<void> onAfterLoad(
      AbstractItemLoadEvent event, Emitter<S> emit, S previousState) async {}

  Stream<Result> resolveStreamData() async* {
    throw UnimplementedError();
  }

  Future<Result> resolveData() async => throw UnimplementedError();

  S convertResultToState(Result result) {
    state.resultStatus = _getStatusFromResult(result) ?? state.resultStatus;

    if (result.isSuccess) {
      state.item = result.data;
    }

    return state.copyWith();
  }

  Future<void> load(AbstractItemLoadEvent event, Emitter<S> emit) async {
    final previousState = state.copyWith();

    if (state is AbstractItemFilterableState) {
      (state as AbstractItemFilterableState).searchModel = event.searchModel ??
          (state as AbstractItemFilterableState).searchModel;
    }

    await onBeforeLoad(event, emit);

    state.resultStatus = ResultStatus.loading;
    updateState(state.copyWith() as S, emit);

    try {
      updateState(convertResultToState(await resolveData()), emit);
    } catch (e) {
      await emit.forEach<Result>(
        resolveStreamData(),
        onData: (result) => convertResultToState(result),
      );
    }

    await onAfterLoad(event, emit, previousState);
  }

  ResultStatus? _getStatusFromResult(Result result) => result.isError
      ? ResultStatus.error
      : result.hasData && result is CacheResult
          ? ResultStatus.loadedCached
          : ResultStatus.loaded;

  void updateState(S state, Emitter<S> emit) {
    if (!isClosed) {
      emit(state);
    }
  }
}
