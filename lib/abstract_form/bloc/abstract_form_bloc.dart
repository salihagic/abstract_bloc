import 'package:abstract_bloc/abstract_bloc.dart';

abstract class AbstractFormBloc<S extends AbstractFormBasicState>
    extends Bloc<AbstractFormEvent, S> {
  AbstractFormBloc(S initialState, [ModelValidator? modelValidator])
      : super(initialState) {
    if (state is AbstractFormState) {
      (state as AbstractFormState).modelValidator = modelValidator;
    }

    on(
      (AbstractFormEvent event, Emitter<S> emit) async {
        if (event is AbstractFormInitEvent) {
          await init(event, emit);
        } else if (event is AbstractFormUpdateEvent) {
          await update(event, emit);
        } else if (event is AbstractFormSubmitEvent) {
          await submit(event, emit);
        }
      },
    );
  }

  // Override this method to initialize referent data or a model from your API
  Future<Result> initModel(
          AbstractFormInitEvent event, Emitter<S> emit) async =>
      Result.success();

  Future<void> init(AbstractFormInitEvent event, Emitter<S> emit) async {
    if (state is AbstractFormState) {
      (state as AbstractFormState).autovalidate = false;
    }
    _changeStatus(emit, FormResultStatus.initializing);

    final result = await initModel(event, emit);

    if (result.isError) {
      _changeStatus(emit, FormResultStatus.error);
    } else {
      if (result.hasData) {
        state.model = result.data;
      }

      _changeStatus(emit, FormResultStatus.initialized);
    }
  }

  Future<void> update(AbstractFormUpdateEvent event, Emitter<S> emit) async {
    (state as AbstractFormState).model = event.model;

    emit(state.copyWith() as S);
  }

  Future<Result> onSubmit(model) => throw Exception('onSubmit Not implemented');

  Future<void> submit(AbstractFormSubmitEvent event, Emitter<S> emit) async {
    final model = event.model ?? state.model;

    if (state is AbstractFormState &&
        !((state as AbstractFormState).modelValidator?.validate(model) ??
            false)) {
      (state as AbstractFormState).autovalidate = true;
      _changeStatus(emit, FormResultStatus.validationError);
      await Future.delayed(const Duration(milliseconds: 100));
      _changeStatus(emit, FormResultStatus.initialized);
    } else {
      state.formResultStatus = FormResultStatus.submitting;
      emit(state.copyWith());

      final result = await onSubmit(model);

      if (result.isSuccess) {
        _changeStatus(emit, FormResultStatus.submittingSuccess);
      } else {
        if (state is AbstractFormState) {
          (state as AbstractFormState).autovalidate = true;
        }
        _changeStatus(emit, FormResultStatus.submittingError);
        await Future.delayed(const Duration(milliseconds: 100));
        _changeStatus(emit, FormResultStatus.initialized);
      }
    }
  }

  void _changeStatus(Emitter<S> emit, FormResultStatus formResultStatus) {
    state.formResultStatus = formResultStatus;
    emit(state.copyWith());
  }
}
