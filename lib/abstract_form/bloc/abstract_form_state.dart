import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter/widgets.dart';

abstract class AbstractFormBasicState<TModel> {
  FormResultStatus formResultStatus;
  TModel? model;

  bool get isInitialized => formResultStatus == FormResultStatus.initialized;
  bool get isSubmitting => formResultStatus == FormResultStatus.submitting;

  AbstractFormBasicState({
    required this.formResultStatus,
    required this.model,
  });

  dynamic copyWith() => this;
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
    required FormResultStatus formResultStatus,
    this.autovalidate = false,
  }) : super(
          formResultStatus: formResultStatus,
        );

  dynamic copyWith() => this;
}
