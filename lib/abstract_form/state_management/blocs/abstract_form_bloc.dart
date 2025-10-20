import 'package:abstract_bloc/abstract_bloc.dart';

/// An abstract BLoC class for managing form states and submission logic.
/// Extends `Bloc` and uses generic state types extending `AbstractFormBaseState`.
abstract class AbstractFormBloc<S extends AbstractFormBaseState>
    extends Bloc<AbstractFormEvent, S> {
  /// Constructor for `AbstractFormBloc`.
  /// - Initializes the state.
  /// - Sets up event handlers for form-related events.
  AbstractFormBloc(super.initialState, [ModelValidator? modelValidator]) {
    // If the state is a form state, assign the model validator.
    if (state is AbstractFormState) {
      (state as AbstractFormState).modelValidator = modelValidator;
    }

    // Event handler for form initialization, updates, and submission.
    on((AbstractFormEvent event, Emitter<S> emit) async {
      if (event is AbstractFormInitEvent) {
        await init(event, emit);
      } else if (event is AbstractFormUpdateEvent) {
        await update(event, emit);
      } else if (event is AbstractFormSubmitEvent) {
        await submit(event, emit);
      }
    });
  }

  /// Method to initialize the form model, typically fetching data from an API.
  /// Can be overridden in subclasses to provide custom initialization logic.
  Future<Result> initModel(
    AbstractFormInitEvent event,
    Emitter<S> emit,
  ) async => Result.success();

  /// Handles the form initialization logic.
  /// - Disables auto-validation initially.
  /// - Updates the form state status to initializing.
  /// - Calls `initModel()` to fetch initial data.
  /// - Updates the form status based on the result.
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

  /// Handles form update events, updating the form model.
  Future<void> update(AbstractFormUpdateEvent event, Emitter<S> emit) async {
    if (state is AbstractFormBasicState) {
      (state as AbstractFormBasicState).model = event.model;
    }
    updateState(state.copyWith() as S, emit);
  }

  /// Abstract submission methods to be implemented in subclasses.
  Future<Result> onSubmit(dynamic model) =>
      throw Exception('onSubmit Not implemented');
  Future<Result> onSubmitEmpty() =>
      throw Exception('onSubmitEmpty Not implemented');
  Future<Result> onSubmitLocal(dynamic model) =>
      throw Exception('onSubmitLocal Not implemented');
  Future<Result> onSubmitEmptyLocal() =>
      throw Exception('onSubmitEmptyLocal Not implemented');

  /// Called when form submission is successful.
  void success() {}

  /// Handles successful form submission.
  Future<void> onSubmitSuccess(Result result, Emitter<S> emit) async {
    updateStatus(emit, FormResultStatus.submittingSuccess);
  }

  /// Handles successful local submission (offline mode).
  Future<void> onSubmitLocalSuccess(Result result, Emitter<S> emit) async {
    updateStatus(emit, FormResultStatus.submittingLocalSuccess);
  }

  /// Handles submission failure due to connection issues.
  Future<void> onConnectionSubmitError(
    Result result,
    Emitter<S> emit,
    dynamic model,
  ) async {
    updateStatus(emit, FormResultStatus.submittingError);
    await Future.delayed(const Duration(milliseconds: 100));
    updateStatus(emit, FormResultStatus.initialized);
  }

  /// Handles submission failure when no connection and no local save is possible.
  Future<void> onConnectionSubmitEmptyError(
    Result result,
    Emitter<S> emit,
  ) async {
    updateStatus(emit, FormResultStatus.submittingError);
    await Future.delayed(const Duration(milliseconds: 100));
    updateStatus(emit, FormResultStatus.initialized);
  }

  /// Handles generic form submission errors.
  Future<void> onSubmitError(Result result, Emitter<S> emit) async {
    if (state is AbstractFormState) {
      (state as AbstractFormState).autovalidate = true;
    }
    updateStatus(emit, FormResultStatus.submittingError);
    await Future.delayed(const Duration(milliseconds: 100));
    updateStatus(emit, FormResultStatus.initialized);
  }

  /// Handles local submission errors.
  Future<void> onSubmitLocalError(Result result, Emitter<S> emit) async {
    if (state is AbstractFormState) {
      (state as AbstractFormState).autovalidate = true;
    }
    updateStatus(emit, FormResultStatus.submittingLocalError);
    await Future.delayed(const Duration(milliseconds: 100));
    updateStatus(emit, FormResultStatus.initialized);
  }

  /// Handles the form submission logic.
  /// - Checks if a submission is already in progress.
  /// - Validates the model using `modelValidator`.
  /// - Calls the appropriate submission method (`onSubmit`, `onSubmitEmpty`).
  /// - Handles success, local submission, and errors accordingly.
  Future<void> submit(AbstractFormSubmitEvent event, Emitter<S> emit) async {
    if ((state as AbstractFormBaseState).isSubmitting) {
      return;
    }

    // Get the model from the event or state
    final model =
        event.model ??
        (state is AbstractFormBasicState
            ? (state as AbstractFormBasicState).model
            : null);

    // Validate the model if a validator exists
    final isValid = state is AbstractFormState
        ? (state as AbstractFormState).modelValidator?.validate(model) ?? false
        : true;

    if (!isValid) {
      (state as AbstractFormState).autovalidate = true;
      updateStatus(emit, FormResultStatus.validationError);
      await Future.delayed(const Duration(milliseconds: 100));
      updateStatus(emit, FormResultStatus.initialized);
    } else {
      state.formResultStatus = FormResultStatus.submitting;
      if (state is AbstractFormBasicState) {
        (state as AbstractFormBasicState).model = model;
      }
      updateState(state.copyWith(), emit);

      final result = model != null
          ? await onSubmit(model)
          : await onSubmitEmpty();

      if (result.isSuccess) {
        await onSubmitSuccess(result, emit);
        success();
      } else {
        if (result.isConnectionError) {
          try {
            final localResult = model != null
                ? await onSubmitLocal(model)
                : await onSubmitEmptyLocal();

            if (localResult.isLocalSuccess) {
              await onSubmitLocalSuccess(result, emit);
            } else {
              await onSubmitLocalError(result, emit);
            }
          } catch (e) {
            model != null
                ? await onConnectionSubmitError(result, model, emit)
                : await onConnectionSubmitEmptyError(result, emit);
          }
        } else {
          await onSubmitError(result, emit);
        }
      }
    }
  }

  /// Updates the form status and emits the new state.
  void updateStatus(Emitter<S> emit, FormResultStatus formResultStatus) {
    state.formResultStatus = formResultStatus;
    updateState(state.copyWith(), emit);
  }

  /// Emits a new state if the BLoC is not closed.
  void updateState(S state, Emitter<S> emit) {
    if (!isClosed) {
      emit(state);
    }
  }
}
