import 'package:abstract_bloc/abstract_bloc.dart';

abstract class AbstractFormState<TItem> {
  FormResultStatus formResultStatus;
  TItem? item;

  bool get hasItem => item != null;
  bool get isLoaded => [ResultStatus.loaded, ResultStatus.loadedCached].contains(formResultStatus);

  AbstractFormState({
    required this.formResultStatus,
    this.item,
  });

  dynamic copyWith() => this;
}

abstract class AbstractFormFilterableState<TSearchModel, TItem> extends AbstractFormState<TItem> {
  TSearchModel searchModel;

  AbstractFormFilterableState({
    required FormResultStatus formResultStatus,
    required this.searchModel,
    TItem? item,
  }) : super(
          formResultStatus: formResultStatus,
          item: item,
        );

  @override
  dynamic copyWith() => this;
}
