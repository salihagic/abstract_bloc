import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rest_api_client/rest_api_client.dart';

abstract class AbstractItemBloc<E extends AbstractItemEvent,
    S extends AbstractItemState> extends Bloc<E, S> {
  AbstractItemBloc(S initialState) : super(initialState) {
    on(
      (E event, Emitter<S> emit) async {
        if (event is AbstractItemLoadEvent) {
          await load(event, emit);
        }
      },
    );
  }

  Future onBeforeLoad() async {}

  Stream<Result> resolveStreamData() async* {
    throw UnimplementedError();
  }

  Future<Result> resolveData() async => throw UnimplementedError();

  S convertResultToState(Result result) {
    state.resultStatus = _getStatusFromResult(result) ?? state.resultStatus;
    state.item = result.data ?? state.item;

    return state.copyWith();
  }

  Future<void> load(AbstractItemLoadEvent event, Emitter<S> emit) async {
    if (state is AbstractItemFilterableState) {
      (state as AbstractItemFilterableState).searchModel = event.searchModel ??
          (state as AbstractItemFilterableState).searchModel;
    }

    await onBeforeLoad();

    state.resultStatus = ResultStatus.loading;
    emit(state.copyWith() as S);

    try {
      emit(convertResultToState(await resolveData()));
    } catch (e) {
      await emit.forEach<Result>(
        resolveStreamData(),
        onData: (result) => convertResultToState(result),
      );
    }
  }

  ResultStatus? _getStatusFromResult(Result result) => result.isError
      ? ResultStatus.error
      : result.hasData && result is CacheResult
          ? ResultStatus.loadedCached
          : ResultStatus.loaded;
}
