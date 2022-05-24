import 'package:abstract_bloc/abstract_bloc.dart';

abstract class AbstractFormBloc<S extends AbstractFormState> extends Bloc<AbstractFormEvent, S> {
  AbstractFormBloc(S initialState) : super(initialState) {
    on(
      (AbstractFormEvent event, Emitter<S> emit) async {
        if (event is AbstractFormInitEvent) {
          await _init(event, emit);
        }
      },
    );
  }

  Future onBeforeLoad() async {}

  Future<Result> resolveData() async => throw UnimplementedError();

  S convertResultToState(Result result) {
    state.formResultStatus = _getStatusFromResult(result) ?? state.formResultStatus;
    if (result.isSuccess) {
      state.item = result.data;
    }

    return state.copyWith();
  }

  Future<void> _init(AbstractFormInitEvent event, Emitter<S> emit) async {
    if (state is AbstractFormFilterableState) {
      (state as AbstractFormFilterableState).searchModel = event.searchModel ?? (state as AbstractFormFilterableState).searchModel;
    }

    await onBeforeLoad();

    state.formResultStatus = FormResultStatus.initializing;
    emit(state.copyWith() as S);
    emit(convertResultToState(await resolveData()));
  }

  FormResultStatus? _getStatusFromResult(Result result) => result.isError ? FormResultStatus.error : FormResultStatus.initialized;
}
