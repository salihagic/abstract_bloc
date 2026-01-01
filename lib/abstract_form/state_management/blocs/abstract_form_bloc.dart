import 'package:abstract_bloc/abstract_bloc.dart';

/// An abstract Bloc for managing form state using the event-driven pattern.
///
/// This class provides a complete solution for form management with:
/// - Form initialization from API or local data
/// - Model validation before submission
/// - Network submission with offline fallback support
/// - Event-driven architecture for better separation of concerns
/// - Automatic state transitions and error handling
///
/// ## Usage
///
/// Extend this class and implement [onSubmit] to handle form submission:
///
/// ```dart
/// class UserFormBloc extends AbstractFormBloc<UserFormState> {
///   final UserRepository _repository;
///
///   UserFormBloc(this._repository)
///       : super(UserFormState.initial(), UserValidator());
///
///   @override
///   Future<Result> initModel(AbstractFormInitEvent event, Emitter emit) async {
///     if (event.model != null) {
///       return _repository.getUser(event.model as String);
///     }
///     return Result.success(data: User.empty());
///   }
///
///   @override
///   Future<Result> onSubmit(dynamic model) async {
///     return _repository.saveUser(model as User);
///   }
/// }
/// ```
///
/// ## Dispatching Events
///
/// Use events to trigger form operations:
///
/// ```dart
/// // Initialize form (for editing)
/// bloc.add(AbstractFormInitEvent(model: userId));
///
/// // Initialize empty form (for creating)
/// bloc.add(AbstractFormInitEvent());
///
/// // Update form model
/// bloc.add(AbstractFormUpdateEvent(model: updatedUser));
///
/// // Submit form
/// bloc.add(AbstractFormSubmitEvent());
///
/// // Submit with explicit model
/// bloc.add(AbstractFormSubmitEvent(model: user));
/// ```
///
/// ## State Requirements
///
/// The state type [S] must extend [AbstractFormBaseState]:
/// - [AbstractFormBaseState]: Basic form state with status only
/// - [AbstractFormBasicState]: Adds a model property
/// - [AbstractFormState]: Full form with model and validator
///
/// ## Bloc vs Cubit
///
/// Use [AbstractFormBloc] when you need:
/// - Event-driven architecture with explicit event types
/// - Better separation between UI and business logic
/// - Event transformation capabilities (debounce, throttle, etc.)
///
/// Use [AbstractFormCubit] when you need:
/// - Simpler API with direct method calls
/// - Less boilerplate code
abstract class AbstractFormBloc<S extends AbstractFormBaseState>
    extends Bloc<AbstractFormEvent, S> {
  /// Creates an [AbstractFormBloc] with the given initial state.
  ///
  /// Automatically registers event handlers for:
  /// - [AbstractFormInitEvent] → [init]
  /// - [AbstractFormUpdateEvent] → [update]
  /// - [AbstractFormSubmitEvent] → [submit]
  ///
  /// Parameters:
  /// - [initialState]: The initial form state
  /// - [modelValidator]: Optional validator for form data. If provided,
  ///   validation runs before submission.
  AbstractFormBloc(super.initialState, [ModelValidator? modelValidator]) {
    if (state is AbstractFormState) {
      (state as AbstractFormState).modelValidator = modelValidator;
    }

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

  /// Fetches and prepares the form model from an external source.
  ///
  /// Override this method to load form data from an API or database.
  /// The event may contain initialization data (e.g., an ID for editing).
  ///
  /// ```dart
  /// @override
  /// Future<Result> initModel(AbstractFormInitEvent event, Emitter emit) async {
  ///   if (event.model != null) {
  ///     // Editing existing - fetch from API
  ///     return _repository.getUser(event.model as String);
  ///   }
  ///   // Creating new - return empty model
  ///   return Result.success(data: User.empty());
  /// }
  /// ```
  ///
  /// Parameters:
  /// - [event]: The init event containing optional initialization data
  /// - [emit]: The emitter for intermediate state updates if needed
  ///
  /// Returns a [Result] containing the loaded model data or an error.
  Future<Result> initModel(
    AbstractFormInitEvent event,
    Emitter<S> emit,
  ) async => Result.success();

  /// Handles the [AbstractFormInitEvent] to initialize the form.
  ///
  /// This method:
  /// 1. Resets autovalidate to prevent premature validation
  /// 2. Sets status to `initializing`
  /// 3. Calls [initModel] to fetch data
  /// 4. Updates status to `initialized` or `error`
  ///
  /// Parameters:
  /// - [event]: Contains optional model data for initialization
  /// - [emit]: The emitter to emit state changes
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

  /// Handles the [AbstractFormUpdateEvent] to update the form model.
  ///
  /// Use this to reflect user input changes in the state.
  /// If autovalidate is enabled, validation feedback updates immediately.
  ///
  /// Parameters:
  /// - [event]: Contains the updated model data
  /// - [emit]: The emitter to emit state changes
  Future<void> update(AbstractFormUpdateEvent event, Emitter<S> emit) async {
    if (state is AbstractFormBasicState) {
      (state as AbstractFormBasicState).model = event.model;
    }
    updateState(state.copyWith() as S, emit);
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
  Future<Result> onSubmitEmpty() =>
      throw Exception('onSubmitEmpty Not implemented');

  /// Submits the form data to local storage as offline fallback.
  ///
  /// This is called automatically when [onSubmit] fails with a
  /// connection error. Override to save data locally for later sync.
  Future<Result> onSubmitLocal(dynamic model) =>
      throw Exception('onSubmitLocal Not implemented');

  /// Submits locally without model data as offline fallback.
  Future<Result> onSubmitEmptyLocal() =>
      throw Exception('onSubmitEmptyLocal Not implemented');

  /// Called after successful form submission.
  ///
  /// Override to perform post-submission actions such as:
  /// - Navigation
  /// - Showing success messages
  /// - Refreshing related data
  void success() {}

  /// Handles successful network submission.
  ///
  /// Updates status to `submittingSuccess`. Override to customize
  /// success handling, such as updating the model with server response.
  ///
  /// Parameters:
  /// - [result]: The successful result from submission
  /// - [emit]: The emitter to emit state changes
  Future<void> onSubmitSuccess(Result result, Emitter<S> emit) async {
    updateStatus(emit, FormResultStatus.submittingSuccess);
  }

  /// Handles successful local submission (offline fallback).
  ///
  /// Updates status to `submittingLocalSuccess`. This indicates
  /// data was saved locally and will sync when connection is restored.
  ///
  /// Parameters:
  /// - [result]: The successful result from local submission
  /// - [emit]: The emitter to emit state changes
  Future<void> onSubmitLocalSuccess(Result result, Emitter<S> emit) async {
    updateStatus(emit, FormResultStatus.submittingLocalSuccess);
  }

  /// Handles connection errors when model submission fails.
  ///
  /// Called when [onSubmit] fails with a connection error and
  /// [onSubmitLocal] is not implemented or also fails.
  ///
  /// Default behavior: Shows error briefly, then returns to initialized.
  ///
  /// Parameters:
  /// - [result]: The error result from submission
  /// - [emit]: The emitter to emit state changes
  /// - [model]: The model that failed to submit
  Future<void> onConnectionSubmitError(
    Result result,
    Emitter<S> emit,
    dynamic model,
  ) async {
    updateStatus(emit, FormResultStatus.submittingError);
    await Future.delayed(const Duration(milliseconds: 100));
    updateStatus(emit, FormResultStatus.initialized);
  }

  /// Handles connection errors when empty submission fails.
  ///
  /// Called when [onSubmitEmpty] fails with a connection error and
  /// [onSubmitEmptyLocal] is not implemented or also fails.
  ///
  /// Parameters:
  /// - [result]: The error result from submission
  /// - [emit]: The emitter to emit state changes
  Future<void> onConnectionSubmitEmptyError(
    Result result,
    Emitter<S> emit,
  ) async {
    updateStatus(emit, FormResultStatus.submittingError);
    await Future.delayed(const Duration(milliseconds: 100));
    updateStatus(emit, FormResultStatus.initialized);
  }

  /// Handles non-connection submission errors.
  ///
  /// Called when [onSubmit] fails with an error other than connection.
  /// Enables autovalidate to show validation feedback after server errors.
  ///
  /// Parameters:
  /// - [result]: The error result from submission
  /// - [emit]: The emitter to emit state changes
  Future<void> onSubmitError(Result result, Emitter<S> emit) async {
    if (state is AbstractFormState) {
      (state as AbstractFormState).autovalidate = true;
    }
    updateStatus(emit, FormResultStatus.submittingError);
    await Future.delayed(const Duration(milliseconds: 100));
    updateStatus(emit, FormResultStatus.initialized);
  }

  /// Handles local submission errors.
  ///
  /// Called when [onSubmitLocal] fails. Enables autovalidate and
  /// updates status to show the error occurred during local save.
  ///
  /// Parameters:
  /// - [result]: The error result from local submission
  /// - [emit]: The emitter to emit state changes
  Future<void> onSubmitLocalError(Result result, Emitter<S> emit) async {
    if (state is AbstractFormState) {
      (state as AbstractFormState).autovalidate = true;
    }
    updateStatus(emit, FormResultStatus.submittingLocalError);
    await Future.delayed(const Duration(milliseconds: 100));
    updateStatus(emit, FormResultStatus.initialized);
  }

  /// Handles the [AbstractFormSubmitEvent] to validate and submit the form.
  ///
  /// This method:
  /// 1. Prevents duplicate submissions if already submitting
  /// 2. Gets the model from the event or state
  /// 3. Validates the model if a validator is configured
  /// 4. Calls [onSubmit] (or [onSubmitEmpty]) for network submission
  /// 5. Falls back to [onSubmitLocal] on connection errors
  /// 6. Handles success/error states appropriately
  ///
  /// Parameters:
  /// - [event]: Contains optional model to submit
  /// - [emit]: The emitter to emit state changes
  Future<void> submit(AbstractFormSubmitEvent event, Emitter<S> emit) async {
    // Prevent concurrent submissions
    if ((state as AbstractFormBaseState).isSubmitting) {
      return;
    }

    // Get the model from event or state
    final model =
        event.model ??
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
      updateStatus(emit, FormResultStatus.validationError);
      await Future.delayed(const Duration(milliseconds: 100));
      updateStatus(emit, FormResultStatus.initialized);
    } else {
      // Validation passed - proceed with submission
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
        // Handle errors with offline fallback for connection issues
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

  /// Updates the form result status and emits a new state.
  ///
  /// This is a convenience method for status-only updates.
  ///
  /// Parameters:
  /// - [emit]: The emitter to emit state changes
  /// - [formResultStatus]: The new form status
  void updateStatus(Emitter<S> emit, FormResultStatus formResultStatus) {
    state.formResultStatus = formResultStatus;
    updateState(state.copyWith(), emit);
  }

  /// Safely emits a new state if the bloc is not closed.
  ///
  /// Use this method instead of direct [emit] calls to prevent
  /// errors when the bloc is disposed during async operations.
  ///
  /// Parameters:
  /// - [state]: The new state to emit
  /// - [emit]: The emitter from the event handler
  void updateState(S state, Emitter<S> emit) {
    if (!isClosed) {
      emit(state);
    }
  }
}
