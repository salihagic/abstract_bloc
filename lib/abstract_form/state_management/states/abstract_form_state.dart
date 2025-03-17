import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter/widgets.dart';

abstract class AbstractFormBaseState implements CopyWith {
  FormResultStatus formResultStatus;

  bool get isInitialized => formResultStatus == FormResultStatus.initialized;
  bool get isSubmitting => formResultStatus == FormResultStatus.submitting;
  bool get isSubmittingSuccess =>
      formResultStatus == FormResultStatus.submittingSuccess;
  bool get isSubmittingError => [
        FormResultStatus.error,
        FormResultStatus.submittingError,
        FormResultStatus.submittingLocalError,
        FormResultStatus.validationError,
      ].contains(formResultStatus);

  AbstractFormBaseState({
    required this.formResultStatus,
  });

  @override
  dynamic copyWith();
}

abstract class AbstractFormBasicState<TModel> extends AbstractFormBaseState {
  TModel? model;

  AbstractFormBasicState({
    required super.formResultStatus,
    required this.model,
  });

  @override
  dynamic copyWith();
}

abstract class AbstractFormState<TModel, TModelValidator extends ModelValidator>
    extends AbstractFormBasicState<TModel> {
  TModelValidator? modelValidator;
  bool autovalidate;

  bool get hasModel => model != null;
  AutovalidateMode get autovalidateMode =>
      autovalidate ? AutovalidateMode.always : AutovalidateMode.disabled;

  AbstractFormState({
    super.model,
    required this.modelValidator,
    required super.formResultStatus,
    this.autovalidate = false,
  });

  @override
  dynamic copyWith();
}
