import 'package:abstract_bloc/abstract_bloc.dart';

abstract class AbstractItemState<TItem> implements CopyWith {
  ResultStatus resultStatus;
  TItem? item;

  bool get hasItem => item != null;
  bool get isLoaded =>
      [ResultStatus.loaded, ResultStatus.loadedCached].contains(resultStatus);

  AbstractItemState({
    required this.resultStatus,
    this.item,
  });

  dynamic copyWith() => this;
}

abstract class AbstractItemFilterableState<TSearchModel, TItem>
    extends AbstractItemState<TItem> {
  TSearchModel searchModel;

  AbstractItemFilterableState({
    required ResultStatus resultStatus,
    required this.searchModel,
    TItem? item,
  }) : super(
          resultStatus: resultStatus,
          item: item,
        );

  @override
  dynamic copyWith() => this;
}
