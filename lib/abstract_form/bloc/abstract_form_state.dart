import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter/widgets.dart';

abstract class AbstractFormBasicState {
  FormResultStatus formResultStatus;

  bool get isInitialized => formResultStatus == FormResultStatus.initialized;
  bool get isSubmitting => formResultStatus == FormResultStatus.submitting;

  AbstractFormBasicState({
    required this.formResultStatus,
  });

  dynamic copyWith() => this;
}

abstract class AbstractFormState<TModel, TModelValidator extends ModelValidator>
    extends AbstractFormBasicState {
  TModel? model;
  TModelValidator? modelValidator;
  bool autovalidate;

  bool get hasModel => model != null;
  AutovalidateMode get autovalidateMode =>
      autovalidate ? AutovalidateMode.always : AutovalidateMode.disabled;

  AbstractFormState({
    this.model,
    required this.modelValidator,
    required FormResultStatus formResultStatus,
    this.autovalidate = false,
  }) : super(
          formResultStatus: formResultStatus,
        );

  dynamic copyWith() => this;
}
