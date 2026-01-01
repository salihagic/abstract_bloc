import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter/widgets.dart';

/// Base state class for managing form data in BLoC/Cubit patterns.
///
/// This abstract class provides the foundation for form state management with:
/// - Form status tracking (initializing, submitting, success, error)
/// - Convenient status check getters
/// - Support for immutable state updates via [CopyWith]
///
/// ## State Hierarchy
///
/// Choose the appropriate state class based on your needs:
/// - [AbstractFormBaseState]: Status tracking only (no model)
/// - [AbstractFormBasicState]: Adds a model property for form data
/// - [AbstractFormState]: Full-featured with model and validation
///
/// ## Usage
///
/// For simple forms without a model, extend this class directly:
///
/// ```dart
/// class ConfirmationFormState extends AbstractFormBaseState {
///   ConfirmationFormState({required super.formResultStatus});
///
///   factory ConfirmationFormState.initial() => ConfirmationFormState(
///     formResultStatus: FormResultStatus.initialized,
///   );
///
///   @override
///   ConfirmationFormState copyWith({FormResultStatus? formResultStatus}) =>
///     ConfirmationFormState(
///       formResultStatus: formResultStatus ?? this.formResultStatus,
///     );
/// }
/// ```
///
/// For most forms, use [AbstractFormBasicState] or [AbstractFormState] instead.
abstract class AbstractFormBaseState implements CopyWith {
  /// Current status of the form operation.
  ///
  /// Possible values:
  /// - [FormResultStatus.initializing]: Form data is being loaded
  /// - [FormResultStatus.initialized]: Form is ready for user input
  /// - [FormResultStatus.submitting]: Form is being submitted
  /// - [FormResultStatus.submittingSuccess]: Submission completed successfully
  /// - [FormResultStatus.submittingLocalSuccess]: Saved locally (offline)
  /// - [FormResultStatus.error]: Initialization failed
  /// - [FormResultStatus.submittingError]: Submission failed
  /// - [FormResultStatus.submittingLocalError]: Local save failed
  /// - [FormResultStatus.validationError]: Model validation failed
  FormResultStatus formResultStatus;

  /// Whether the form has been successfully initialized.
  ///
  /// Returns `true` when [formResultStatus] is `initialized`.
  /// Use this to determine if the form is ready for user input.
  bool get isInitialized => formResultStatus == FormResultStatus.initialized;

  /// Whether the form is currently being submitted.
  ///
  /// Returns `true` when [formResultStatus] is `submitting`.
  /// Use this to disable form inputs and show loading indicators.
  bool get isSubmitting => formResultStatus == FormResultStatus.submitting;

  /// Whether the form submission was successful.
  ///
  /// Returns `true` when [formResultStatus] is `submittingSuccess`.
  /// Use this to trigger navigation or show success messages.
  bool get isSubmittingSuccess =>
      formResultStatus == FormResultStatus.submittingSuccess;

  /// Whether the form encountered any error.
  ///
  /// Returns `true` for any error status:
  /// - `error`: Initialization error
  /// - `submittingError`: Network submission error
  /// - `submittingLocalError`: Local save error
  /// - `validationError`: Model validation error
  ///
  /// Use this for general error display logic.
  bool get isSubmittingError => [
    FormResultStatus.error,
    FormResultStatus.submittingError,
    FormResultStatus.submittingLocalError,
    FormResultStatus.validationError,
  ].contains(formResultStatus);

  /// Creates an [AbstractFormBaseState].
  ///
  /// Parameters:
  /// - [formResultStatus]: Initial form status (typically `initializing`)
  AbstractFormBaseState({required this.formResultStatus});

  /// Creates a copy of this state with optionally modified properties.
  ///
  /// Subclasses must implement this to enable immutable state updates.
  @override
  dynamic copyWith();
}

/// State class for forms that manage a data model.
///
/// Extends [AbstractFormBaseState] to add a generic model property
/// for storing and managing form data.
///
/// ## Usage
///
/// ```dart
/// class UserFormState extends AbstractFormBasicState<User> {
///   UserFormState({
///     required super.formResultStatus,
///     required super.model,
///   });
///
///   factory UserFormState.initial() => UserFormState(
///     formResultStatus: FormResultStatus.initializing,
///     model: null, // Will be loaded during init
///   );
///
///   @override
///   UserFormState copyWith({
///     FormResultStatus? formResultStatus,
///     User? model,
///   }) => UserFormState(
///     formResultStatus: formResultStatus ?? this.formResultStatus,
///     model: model ?? this.model,
///   );
/// }
/// ```
///
/// Type parameter [TModel] defines the type of form data being managed.
abstract class AbstractFormBasicState<TModel> extends AbstractFormBaseState {
  /// The form data model.
  ///
  /// This property stores the current form data. It is:
  /// - Set during [init] from the loaded data
  /// - Updated via [update] when the user modifies the form
  /// - Submitted via [submit] to save the form
  ///
  /// May be `null` during initialization or for create-new scenarios.
  TModel? model;

  /// Creates an [AbstractFormBasicState].
  ///
  /// Parameters:
  /// - [formResultStatus]: Initial form status
  /// - [model]: Initial model (can be null for new entries)
  AbstractFormBasicState({
    required super.formResultStatus,
    required this.model,
  });

  /// Creates a copy of this state with optionally modified properties.
  @override
  dynamic copyWith();
}

/// Full-featured state class for forms with model and validation support.
///
/// Extends [AbstractFormBasicState] to add:
/// - Model validation via [ModelValidator]
/// - Auto-validation mode for real-time feedback
/// - Flutter [AutovalidateMode] integration
///
/// ## Usage
///
/// ```dart
/// class UserFormState extends AbstractFormState<User, UserValidator> {
///   UserFormState({
///     required super.formResultStatus,
///     super.model,
///     super.modelValidator,
///     super.autovalidate,
///   });
///
///   factory UserFormState.initial() => UserFormState(
///     formResultStatus: FormResultStatus.initializing,
///     model: null,
///     modelValidator: UserValidator(),
///     autovalidate: false,
///   );
///
///   @override
///   UserFormState copyWith({...}) => UserFormState(...);
/// }
///
/// // Custom validator
/// class UserValidator extends ModelValidator {
///   @override
///   bool validate(dynamic model) {
///     if (model is! User) return false;
///     return model.name.isNotEmpty && model.email.contains('@');
///   }
/// }
/// ```
///
/// ## Validation Workflow
///
/// 1. User submits form → [submit] calls validator
/// 2. If invalid → [autovalidate] set to `true`, status = `validationError`
/// 3. Form rebuilds with [autovalidateMode] = `always`
/// 4. Each field shows validation errors immediately
/// 5. User fixes errors and submits again
///
/// Type parameters:
/// - [TModel]: The type of form data being managed
/// - [TModelValidator]: The validator class (extends [ModelValidator])
abstract class AbstractFormState<TModel, TModelValidator extends ModelValidator>
    extends AbstractFormBasicState<TModel> {
  /// Validator instance for model validation.
  ///
  /// Called before submission to validate the form data.
  /// If validation fails, [autovalidate] is enabled for real-time feedback.
  ///
  /// Can be `null` for forms that don't require validation.
  TModelValidator? modelValidator;

  /// Whether the form should validate on every change.
  ///
  /// Initially `false` to avoid showing errors before first submission.
  /// Set to `true` after a failed validation attempt.
  ///
  /// Controls [autovalidateMode] for Flutter form integration.
  bool autovalidate;

  /// Whether the form has a model loaded.
  ///
  /// Shorthand for `model != null`.
  /// Use this to conditionally render form content.
  bool get hasModel => model != null;

  /// Flutter [AutovalidateMode] based on [autovalidate] state.
  ///
  /// Returns:
  /// - [AutovalidateMode.always] when [autovalidate] is `true`
  /// - [AutovalidateMode.disabled] when [autovalidate] is `false`
  ///
  /// Pass this to Flutter's [Form.autovalidateMode] for automatic integration:
  ///
  /// ```dart
  /// Form(
  ///   autovalidateMode: state.autovalidateMode,
  ///   child: ...
  /// )
  /// ```
  AutovalidateMode get autovalidateMode =>
      autovalidate ? AutovalidateMode.always : AutovalidateMode.disabled;

  /// Whether the current model passes validation.
  ///
  /// Returns `true` if:
  /// - No validator is configured, OR
  /// - The validator returns `true` for the current model
  ///
  /// Use this for submit button enabled state or validation indicators.
  bool get isValid => modelValidator?.validate(model) ?? true;

  /// Creates an [AbstractFormState].
  ///
  /// Parameters:
  /// - [model]: Initial model (can be null for new entries)
  /// - [modelValidator]: Validator for form data (can be null)
  /// - [formResultStatus]: Initial form status
  /// - [autovalidate]: Whether to validate on every change (default: false)
  AbstractFormState({
    super.model,
    required this.modelValidator,
    required super.formResultStatus,
    this.autovalidate = false,
  });

  /// Creates a copy of this state with optionally modified properties.
  @override
  dynamic copyWith();
}
