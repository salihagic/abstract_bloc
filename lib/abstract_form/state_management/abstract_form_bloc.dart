import 'package:abstract_bloc/abstract_bloc.dart';

abstract class AbstractFormBloc<S extends AbstractFormBaseState> extends Bloc<AbstractFormEvent, S> {
  AbstractFormBloc(S initialState, [ModelValidator? modelValidator]) : super(initialState) {
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
  Future<Result> initModel(AbstractFormInitEvent event, Emitter<S> emit) async => Result.success();

  Future<void> init(AbstractFormInitEvent event, Emitter<S> emit) async {
    if (state is AbstractFormState) {
      (state as AbstractFormState).autovalidate = false;
    }
    updateStatus(emit, FormResultStatus.initializing);

    final result = await initModel(event, emit);

    if (result.isError) {
      updateStatus(emit, FormResultStatus.error);
    } else {
      if (result.hasData) {
        if (state is AbstractFormBasicState) {
          (state as AbstractFormBasicState).model = result.data;
        }
      }

      updateStatus(emit, FormResultStatus.initialized);
    }
  }

  Future<void> update(AbstractFormUpdateEvent event, Emitter<S> emit) async {
    if (state is AbstractFormBasicState) {
      (state as AbstractFormBasicState).model = event.model;
    }

    updateState(state.copyWith() as S, emit);
  }

  Future<Result> onSubmit(model) => throw Exception('onSubmit Not implemented');
  Future<Result> onSubmitEmpty() => throw Exception('onSubmitEmpty Not implemented');
  Future<Result> onSubmitLocal(model) => throw Exception('onSubmitLocal Not implemented');
  Future<Result> onSubmitEmptyLocal() => throw Exception('onSubmitEmptyLocal Not implemented');

  void success() {}
  Future<void> onSubmitSuccess(Result result, Emitter<S> emit) async {
    updateStatus(emit, FormResultStatus.submittingSuccess);
  }

  Future<void> onSubmitLocalSuccess(Result result, Emitter<S> emit) async {
    updateStatus(emit, FormResultStatus.submittingLocalSuccess);
  }

  Future<void> onConnectionSubmitError(Result result, Emitter<S> emit, dynamic model) async {
    updateStatus(emit, FormResultStatus.submittingError);
    await Future.delayed(const Duration(milliseconds: 100));
    updateStatus(emit, FormResultStatus.initialized);
  }

  Future<void> onConnectionSubmitEmptyError(Result result, Emitter<S> emit) async {
    updateStatus(emit, FormResultStatus.submittingError);
    await Future.delayed(const Duration(milliseconds: 100));
    updateStatus(emit, FormResultStatus.initialized);
  }

  Future<void> onSubmitError(Result result, Emitter<S> emit) async {
    if (state is AbstractFormState) {
      (state as AbstractFormState).autovalidate = true;
    }
    updateStatus(emit, FormResultStatus.submittingError);
    await Future.delayed(const Duration(milliseconds: 100));
    updateStatus(emit, FormResultStatus.initialized);
  }

  Future<void> onSubmitLocalError(Result result, Emitter<S> emit) async {
    if (state is AbstractFormState) {
      (state as AbstractFormState).autovalidate = true;
    }
    updateStatus(emit, FormResultStatus.submittingLocalError);
    await Future.delayed(const Duration(milliseconds: 100));
    updateStatus(emit, FormResultStatus.initialized);
  }

  Future<void> submit(AbstractFormSubmitEvent event, Emitter<S> emit) async {
    final model = event.model ?? (state is AbstractFormBasicState ? (state as AbstractFormBasicState).model : null);

    if (state is AbstractFormState && !((state as AbstractFormState).modelValidator?.validate(model) ?? true)) {
      (state as AbstractFormState).autovalidate = true;
      updateStatus(emit, FormResultStatus.validationError);
      await Future.delayed(const Duration(milliseconds: 100));
      updateStatus(emit, FormResultStatus.initialized);
    } else {
      state.formResultStatus = FormResultStatus.submitting;
      updateState(state.copyWith(), emit);

      final result = model != null ? await onSubmit(model) : await onSubmitEmpty();

      if (result.isSuccess) {
        await onSubmitSuccess(result, emit);
        success();
      } else {
        if (result.isConnectionError) {
          try {
            final localResult = model != null ? await onSubmitLocal(model) : await onSubmitEmptyLocal();

            if (localResult.isLocalSuccess) {
              await onSubmitLocalSuccess(result, emit);
            } else {
              await onSubmitLocalError(result, emit);
            }
          } catch (e) {
            model != null ? await onConnectionSubmitError(result, model, emit) : await onConnectionSubmitEmptyError(result, emit);
          }
        } else {
          await onSubmitError(result, emit);
        }
      }
    }
  }

  void updateStatus(Emitter<S> emit, FormResultStatus formResultStatus) {
    state.formResultStatus = formResultStatus;
    updateState(state.copyWith(), emit);
  }

  void updateState(S state, Emitter<S> emit) {
    if (!isClosed) {
      emit(state);
    }
  }
}
