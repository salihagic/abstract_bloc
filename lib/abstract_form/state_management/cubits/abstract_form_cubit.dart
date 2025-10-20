import 'package:abstract_bloc/abstract_bloc.dart';

/// A base cubit class for managing form states and operations.
/// This class extends [Cubit] and provides methods for initializing, updating,
/// and submitting form data. It also handles validation and error states.
abstract class AbstractFormCubit<S extends AbstractFormBaseState>
    extends Cubit<S> {
  /// Creates an [AbstractFormCubit].
  /// - [initialState]: The initial state of the cubit.
  /// - [modelValidator]: An optional validator for the model (can be null).
  AbstractFormCubit(super.initialState, [ModelValidator? modelValidator]) {
    // If the state is an [AbstractFormState], assign the model validator
    if (state is AbstractFormState) {
      (state as AbstractFormState).modelValidator = modelValidator;
    }
  }

  /// Initializes the form model with data from an API or other source.
  /// Override this method to provide custom initialization logic.
  Future<Result> initModel(model) async => Result.success(data: model);

  /// Initializes the form model with an empty state.
  Future<Result> initModelEmpty() async => Result.success();

  /// Initializes the form cubit with optional model data.
  /// - [model]: Optional data to initialize the form model.
  Future<void> init<T>([T? model]) async {
    if (state is AbstractFormState) {
      (state as AbstractFormState).autovalidate = false;
    }
    updateStatus(FormResultStatus.initializing);

    // Initialize the model with provided data or an empty state
    final result = model != null
        ? await initModel(model)
        : await initModelEmpty();

    if (result.isError) {
      updateStatus(FormResultStatus.error);
    } else {
      if (result.hasData) {
        if (state is AbstractFormBasicState) {
          (state as AbstractFormBasicState).model = result.data;
        }
      }

      updateStatus(FormResultStatus.initialized);
    }
  }

  /// Updates the form model with new data.
  /// - [model]: The new data to update the form model.
  Future<void> update<T>(T model) async {
    if (state is AbstractFormBasicState) {
      (state as AbstractFormBasicState).model = model;
    }

    updateState(state.copyWith() as S);
  }

  /// Submits the form with the provided model.
  /// Throws an exception if not implemented.
  Future<Result> onSubmit(model) => throw Exception('onSubmit Not implemented');

  /// Submits the form with an empty model.
  /// Throws an exception if not implemented.
  Future<Result> onSubmitEmpty() =>
      throw Exception('onSubmitEmpty Not implemented');

  /// Submits the form locally with the provided model.
  /// Throws an exception if not implemented.
  Future<Result> onSubmitLocal(model) =>
      throw Exception('onSubmitLocal Not implemented');

  /// Submits the form locally with an empty model.
  /// Throws an exception if not implemented.
  Future<Result> onSubmitEmptyLocal() =>
      throw Exception('onSubmitEmptyLocal Not implemented');

  /// Called when the form submission is successful.
  void success() {}

  /// Handles successful form submission.
  Future<void> onSubmitSuccess(Result result) async {
    updateStatus(FormResultStatus.submittingSuccess);
  }

  /// Handles successful local form submission.
  Future<void> onSubmitLocalSuccess(Result result) async {
    updateStatus(FormResultStatus.submittingLocalSuccess);
  }

  /// Handles connection errors during form submission.
  Future<void> onConnectionSubmitError(Result result, dynamic model) async {
    updateStatus(FormResultStatus.submittingError);
    await Future.delayed(const Duration(milliseconds: 100));
    updateStatus(FormResultStatus.initialized);
  }

  /// Handles connection errors during form submission with an empty model.
  Future<void> onConnectionSubmitEmptyError(Result result) async {
    updateStatus(FormResultStatus.submittingError);
    await Future.delayed(const Duration(milliseconds: 100));
    updateStatus(FormResultStatus.initialized);
  }

  /// Handles form submission errors.
  Future<void> onSubmitError(Result result) async {
    if (state is AbstractFormState) {
      (state as AbstractFormState).autovalidate = true;
    }
    updateStatus(FormResultStatus.submittingError);
    await Future.delayed(const Duration(milliseconds: 100));
    updateStatus(FormResultStatus.initialized);
  }

  /// Handles local form submission errors.
  Future<void> onSubmitLocalError(Result result) async {
    if (state is AbstractFormState) {
      (state as AbstractFormState).autovalidate = true;
    }
    updateStatus(FormResultStatus.submittingLocalError);
    await Future.delayed(const Duration(milliseconds: 100));
    updateStatus(FormResultStatus.initialized);
  }

  /// Submits the form with optional model data.
  /// - [pModel]: Optional model data to submit.
  Future<void> submit<T>([T? pModel]) async {
    if ((state as AbstractFormBaseState).isSubmitting) {
      return;
    }

    final model =
        pModel ??
        (state is AbstractFormBasicState
            ? (state as AbstractFormBasicState).model
            : null);
    final isValid = state is AbstractFormState
        ? (state as AbstractFormState).modelValidator?.validate(model) ?? false
        : true;

    if (!isValid) {
      (state as AbstractFormState).autovalidate = true;
      updateStatus(FormResultStatus.validationError);
      await Future.delayed(const Duration(milliseconds: 100));
      updateStatus(FormResultStatus.initialized);
    } else {
      state.formResultStatus = FormResultStatus.submitting;
      if (state is AbstractFormBasicState) {
        (state as AbstractFormBasicState).model = model;
      }
      updateState(state.copyWith());

      final result = model != null
          ? await onSubmit(model)
          : await onSubmitEmpty();

      if (result.isSuccess) {
        await onSubmitSuccess(result);
        success();
      } else {
        if (result.isConnectionError) {
          try {
            final localResult = model != null
                ? await onSubmitLocal(model)
                : await onSubmitEmptyLocal();

            if (localResult.isLocalSuccess) {
              await onSubmitLocalSuccess(result);
            } else {
              await onSubmitLocalError(result);
            }
          } catch (e) {
            model != null
                ? await onConnectionSubmitError(result, model)
                : await onConnectionSubmitEmptyError(result);
          }
        } else {
          await onSubmitError(result);
        }
      }
    }
  }

  /// Updates the form status.
  /// - [formResultStatus]: The new status to update.
  void updateStatus(FormResultStatus formResultStatus) {
    state.formResultStatus = formResultStatus;
    updateState(state.copyWith());
  }

  /// Updates the cubit's state.
  /// - [state]: The new state to emit.
  void updateState(S state) {
    if (!isClosed) {
      emit(state);
    }
  }
}
