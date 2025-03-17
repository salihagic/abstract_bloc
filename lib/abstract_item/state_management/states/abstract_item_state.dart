import 'package:abstract_bloc/abstract_bloc.dart';

abstract class AbstractItemState<TItem> implements CopyWith {
  ResultStatus resultStatus;
  TItem? item;

  bool get hasItem => item != null;
  bool get isLoadedAny =>
      [ResultStatus.loaded, ResultStatus.loadedCached].contains(resultStatus);
  bool get isLoadedNetwork => ResultStatus.loaded == resultStatus;
  bool get isLoadedCached => ResultStatus.loadedCached == resultStatus;

  AbstractItemState({
    required this.resultStatus,
    this.item,
  });

  @override
  dynamic copyWith();
}

abstract class AbstractItemFilterableState<TSearchModel, TItem>
    extends AbstractItemState<TItem> {
  TSearchModel searchModel;

  AbstractItemFilterableState({
    required super.resultStatus,
    required this.searchModel,
    super.item,
  });

  @override
  dynamic copyWith();
}
