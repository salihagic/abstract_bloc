import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter/widgets.dart';

/// A base abstract class for form states.
/// This class provides common properties and methods for form-related states,
/// such as status tracking and copying state.
abstract class AbstractFormBaseState implements CopyWith {
  FormResultStatus formResultStatus;

  /// Returns `true` if the form is initialized.
  bool get isInitialized => formResultStatus == FormResultStatus.initialized;

  /// Returns `true` if the form is currently submitting.
  bool get isSubmitting => formResultStatus == FormResultStatus.submitting;

  /// Returns `true` if the form submission was successful.
  bool get isSubmittingSuccess =>
      formResultStatus == FormResultStatus.submittingSuccess;

  /// Returns `true` if the form submission encountered an error.
  bool get isSubmittingError => [
        FormResultStatus.error,
        FormResultStatus.submittingError,
        FormResultStatus.submittingLocalError,
        FormResultStatus.validationError,
      ].contains(formResultStatus);

  /// Creates an [AbstractFormBaseState].
  /// - [formResultStatus]: The current status of the form.
  AbstractFormBaseState({
    required this.formResultStatus,
  });

  @override
  dynamic copyWith();
}

/// A base abstract class for form states that include a model.
/// This class extends [AbstractFormBaseState] and adds a generic model property.
abstract class AbstractFormBasicState<TModel> extends AbstractFormBaseState {
  TModel? model;

  /// Creates an [AbstractFormBasicState].
  /// - [formResultStatus]: The current status of the form.
  /// - [model]: The model associated with the form.
  AbstractFormBasicState({
    required super.formResultStatus,
    required this.model,
  });

  @override
  dynamic copyWith();
}

/// A base abstract class for form states that include a model and a validator.
/// This class extends [AbstractFormBasicState] and adds validation-related properties.
abstract class AbstractFormState<TModel, TModelValidator extends ModelValidator>
    extends AbstractFormBasicState<TModel> {
  TModelValidator? modelValidator;
  bool autovalidate;

  /// Returns `true` if the form has a model.
  bool get hasModel => model != null;

  /// Returns the [AutovalidateMode] based on the `autovalidate` property.
  AutovalidateMode get autovalidateMode =>
      autovalidate ? AutovalidateMode.always : AutovalidateMode.disabled;

  /// Creates an [AbstractFormState].
  /// - [model]: The model associated with the form.
  /// - [modelValidator]: The validator for the form model.
  /// - [formResultStatus]: The current status of the form.
  /// - [autovalidate]: Whether the form should auto-validate.
  AbstractFormState({
    super.model,
    required this.modelValidator,
    required super.formResultStatus,
    this.autovalidate = false,
  });

  @override
  dynamic copyWith();
}
