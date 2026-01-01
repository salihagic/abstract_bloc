import 'package:abstract_bloc/abstract_bloc.dart';

/// An abstract Cubit for managing form state with support for initialization,
/// validation, submission, and offline fallback.
///
/// This class provides a complete solution for form management with:
/// - Form initialization from API or local data
/// - Model validation before submission
/// - Network submission with offline fallback support
/// - Automatic state transitions and error handling
/// - Lifecycle hooks for customization
///
/// ## Usage
///
/// Extend this class and implement [onSubmit] to handle form submission:
///
/// ```dart
/// class UserFormCubit extends AbstractFormCubit<UserFormState> {
///   final UserRepository _repository;
///
///   UserFormCubit(this._repository)
///       : super(UserFormState.initial(), UserValidator());
///
///   @override
///   Future<Result> onSubmit(dynamic model) async {
///     return _repository.saveUser(model as User);
///   }
/// }
/// ```
///
/// ## State Requirements
///
/// The state type [S] must extend [AbstractFormBaseState]:
/// - [AbstractFormBaseState]: Basic form state with status only
/// - [AbstractFormBasicState]: Adds a model property
/// - [AbstractFormState]: Full form with model and validator
///
/// ## Form Lifecycle
///
/// 1. **Initialization**: Call [init] to load form data
///    - Status: `initializing` → `initialized` (or `error`)
///
/// 2. **Updates**: Call [update] to modify the model
///    - Triggers validation if `autovalidate` is enabled
///
/// 3. **Submission**: Call [submit] to save the form
///    - Status: `submitting` → `submittingSuccess` (or error states)
///
/// ## Offline Support
///
/// When [onSubmit] fails with a connection error, the cubit automatically
/// attempts [onSubmitLocal] as a fallback for offline-first scenarios.
abstract class AbstractFormCubit<S extends AbstractFormBaseState>
    extends Cubit<S> {
  /// Creates an [AbstractFormCubit] with the given initial state.
  ///
  /// Parameters:
  /// - [initialState]: The initial form state
  /// - [modelValidator]: Optional validator for form data. If provided,
  ///   validation runs before submission.
  ///
  /// ```dart
  /// UserFormCubit() : super(
  ///   UserFormState.initial(),
  ///   UserValidator(), // Optional
  /// );
  /// ```
  AbstractFormCubit(super.initialState, [ModelValidator? modelValidator]) {
    if (state is AbstractFormState) {
      (state as AbstractFormState).modelValidator = modelValidator;
    }
  }

  /// Fetches and prepares the form model from an external source.
  ///
  /// Override this method to load form data from an API or database.
  /// Called by [init] when a model identifier is provided.
  ///
  /// ```dart
  /// @override
  /// Future<Result> initModel(dynamic model) async {
  ///   // model is typically an ID or partial data
  ///   return _repository.getUser(model as String);
  /// }
  /// ```
  ///
  /// Returns a [Result] containing the loaded model data or an error.
  Future<Result> initModel(dynamic model) async => Result.success(data: model);

  /// Prepares an empty form model for new entries.
  ///
  /// Override this method to create a default model or fetch
  /// related data (e.g., dropdown options) for new forms.
  ///
  /// ```dart
  /// @override
  /// Future<Result> initModelEmpty() async {
  ///   return Result.success(data: User.empty());
  /// }
  /// ```
  Future<Result> initModelEmpty() async => Result.success();

  /// Initializes the form with optional model data.
  ///
  /// This method:
  /// 1. Resets autovalidate to prevent premature validation
  /// 2. Sets status to `initializing`
  /// 3. Calls [initModel] or [initModelEmpty] to fetch data
  /// 4. Updates status to `initialized` or `error`
  ///
  /// Call this when the form screen opens:
  ///
  /// ```dart
  /// // For editing existing data
  /// cubit.init(userId);
  ///
  /// // For creating new entry
  /// cubit.init();
  /// ```
  Future<void> init<T>([T? model]) async {
    if (state is AbstractFormState) {
      (state as AbstractFormState).autovalidate = false;
    }
    updateStatus(FormResultStatus.initializing);

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

  /// Updates the form model without triggering submission.
  ///
  /// Use this to reflect user input changes in the state.
  /// If autovalidate is enabled, validation feedback updates immediately.
  ///
  /// ```dart
  /// void onNameChanged(String name) {
  ///   cubit.update(state.model.copyWith(name: name));
  /// }
  /// ```
  Future<void> update<T>(T model) async {
    if (state is AbstractFormBasicState) {
      (state as AbstractFormBasicState).model = model;
    }

    updateState(state.copyWith() as S);
  }

  /// Submits the form data to the primary (network) destination.
  ///
  /// This is the main submission handler. Override to implement
  /// your API call or database operation.
  ///
  /// ```dart
  /// @override
  /// Future<Result> onSubmit(dynamic model) async {
  ///   return _repository.createUser(model as User);
  /// }
  /// ```
  ///
  /// Returns a [Result] indicating success or failure.
  /// Throws an exception if not implemented when called.
  Future<Result> onSubmit(dynamic model) =>
      throw Exception('onSubmit Not implemented');

  /// Submits the form without model data.
  ///
  /// Override this for forms that don't require model data,
  /// such as simple action confirmations.
  ///
  /// ```dart
  /// @override
  /// Future<Result> onSubmitEmpty() async {
  ///   return _repository.confirmAction();
  /// }
  /// ```
  Future<Result> onSubmitEmpty() =>
      throw Exception('onSubmitEmpty Not implemented');

  /// Submits the form data to local storage as offline fallback.
  ///
  /// This is called automatically when [onSubmit] fails with a
  /// connection error. Override to save data locally for later sync.
  ///
  /// ```dart
  /// @override
  /// Future<Result> onSubmitLocal(dynamic model) async {
  ///   return _localStorage.saveUserForSync(model as User);
  /// }
  /// ```
  Future<Result> onSubmitLocal(dynamic model) =>
      throw Exception('onSubmitLocal Not implemented');

  /// Submits locally without model data as offline fallback.
  ///
  /// Override for forms that don't require model data but need
  /// offline support.
  Future<Result> onSubmitEmptyLocal() =>
      throw Exception('onSubmitEmptyLocal Not implemented');

  /// Called after successful form submission.
  ///
  /// Override to perform post-submission actions such as:
  /// - Navigation
  /// - Showing success messages
  /// - Refreshing related data
  ///
  /// ```dart
  /// @override
  /// void success() {
  ///   _analytics.trackFormSubmitted();
  /// }
  /// ```
  void success() {}

  /// Handles successful network submission.
  ///
  /// Updates status to `submittingSuccess`. Override to customize
  /// success handling, such as updating the model with server response.
  ///
  /// ```dart
  /// @override
  /// Future<void> onSubmitSuccess(Result result) async {
  ///   // Update model with server-generated ID
  ///   if (state is AbstractFormBasicState && result.hasData) {
  ///     (state as AbstractFormBasicState).model = result.data;
  ///   }
  ///   await super.onSubmitSuccess(result);
  /// }
  /// ```
  Future<void> onSubmitSuccess(Result result) async {
    updateStatus(FormResultStatus.submittingSuccess);
  }

  /// Handles successful local submission (offline fallback).
  ///
  /// Updates status to `submittingLocalSuccess`. This indicates
  /// data was saved locally and will sync when connection is restored.
  Future<void> onSubmitLocalSuccess(Result result) async {
    updateStatus(FormResultStatus.submittingLocalSuccess);
  }

  /// Handles connection errors when model submission fails.
  ///
  /// Called when [onSubmit] fails with a connection error and
  /// [onSubmitLocal] is not implemented or also fails.
  ///
  /// Default behavior: Shows error briefly, then returns to initialized.
  Future<void> onConnectionSubmitError(Result result, dynamic model) async {
    updateStatus(FormResultStatus.submittingError);
    await Future.delayed(const Duration(milliseconds: 100));
    updateStatus(FormResultStatus.initialized);
  }

  /// Handles connection errors when empty submission fails.
  ///
  /// Called when [onSubmitEmpty] fails with a connection error and
  /// [onSubmitEmptyLocal] is not implemented or also fails.
  Future<void> onConnectionSubmitEmptyError(Result result) async {
    updateStatus(FormResultStatus.submittingError);
    await Future.delayed(const Duration(milliseconds: 100));
    updateStatus(FormResultStatus.initialized);
  }

  /// Handles non-connection submission errors.
  ///
  /// Called when [onSubmit] fails with an error other than connection.
  /// Enables autovalidate to show validation feedback after server errors.
  Future<void> onSubmitError(Result result) async {
    if (state is AbstractFormState) {
      (state as AbstractFormState).autovalidate = true;
    }
    updateStatus(FormResultStatus.submittingError);
    await Future.delayed(const Duration(milliseconds: 100));
    updateStatus(FormResultStatus.initialized);
  }

  /// Handles local submission errors.
  ///
  /// Called when [onSubmitLocal] fails. Enables autovalidate and
  /// updates status to show the error occurred during local save.
  Future<void> onSubmitLocalError(Result result) async {
    if (state is AbstractFormState) {
      (state as AbstractFormState).autovalidate = true;
    }
    updateStatus(FormResultStatus.submittingLocalError);
    await Future.delayed(const Duration(milliseconds: 100));
    updateStatus(FormResultStatus.initialized);
  }

  /// Validates and submits the form.
  ///
  /// This is the primary submission method. It:
  /// 1. Prevents duplicate submissions if already submitting
  /// 2. Validates the model if a validator is configured
  /// 3. Calls [onSubmit] (or [onSubmitEmpty]) for network submission
  /// 4. Falls back to [onSubmitLocal] on connection errors
  /// 5. Handles success/error states appropriately
  ///
  /// ```dart
  /// // Submit with current model
  /// cubit.submit();
  ///
  /// // Submit with explicit model
  /// cubit.submit(updatedUser);
  /// ```
  ///
  /// Parameters:
  /// - [pModel]: Optional model to submit. If not provided, uses the
  ///   model from state (for [AbstractFormBasicState]).
  Future<void> submit<T>([T? pModel]) async {
    // Prevent concurrent submissions
    if ((state as AbstractFormBaseState).isSubmitting) {
      return;
    }

    final model =
        pModel ??
        (state is AbstractFormBasicState
            ? (state as AbstractFormBasicState).model
            : null);

    // Validate if validator is configured
    final isValid = state is AbstractFormState
        ? (state as AbstractFormState).modelValidator?.validate(model) ?? false
        : true;

    if (!isValid) {
      // Validation failed - enable autovalidate for immediate feedback
      (state as AbstractFormState).autovalidate = true;
      updateStatus(FormResultStatus.validationError);
      await Future.delayed(const Duration(milliseconds: 100));
      updateStatus(FormResultStatus.initialized);
    } else {
      // Validation passed - proceed with submission
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
        // Handle errors with offline fallback for connection issues
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

  /// Updates the form result status and emits a new state.
  ///
  /// This is a convenience method for status-only updates.
  /// For complex state changes, use [updateState] directly.
  void updateStatus(FormResultStatus formResultStatus) {
    state.formResultStatus = formResultStatus;
    updateState(state.copyWith());
  }

  /// Safely emits a new state if the cubit is not closed.
  ///
  /// Use this method instead of direct [emit] calls to prevent
  /// errors when the cubit is disposed during async operations.
  void updateState(S state) {
    if (!isClosed) {
      emit(state);
    }
  }
}
