import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter/widgets.dart';

abstract class AbstractFormState<TModel,
    TModelValidator extends ModelValidator> {
  FormResultStatus formResultStatus;
  TModel? model;
  TModelValidator? modelValidator;
  bool autovalidate;

  bool get hasModel => model != null;
  bool get isInitialized => formResultStatus == FormResultStatus.initialized;
  bool get isSubmitting => formResultStatus == FormResultStatus.submitting;
  AutovalidateMode get autovalidateMode =>
      autovalidate ? AutovalidateMode.always : AutovalidateMode.disabled;

  AbstractFormState({
    required this.formResultStatus,
    this.model,
    required this.modelValidator,
    this.autovalidate = false,
  });

  dynamic copyWith() => this;
}

abstract class AbstractFormFilterableState<TSearchModel, TModel,
        TModelValidator extends ModelValidator>
    extends AbstractFormState<TModel, TModelValidator> {
  TSearchModel? searchModel;

  AbstractFormFilterableState({
    this.searchModel,
    required FormResultStatus formResultStatus,
    TModel? model,
    TModelValidator? modelValidator,
    bool autovalidate = false,
  }) : super(
          formResultStatus: formResultStatus,
          model: model,
          modelValidator: modelValidator,
          autovalidate: autovalidate,
        );

  @override
  dynamic copyWith() => this;
}
