import 'package:abstract_bloc/abstract_bloc.dart';

abstract class ItemState<TItem> {
  ResultStatus resultStatus;
  TItem? item;

  bool get hasItem => item != null;
  bool get isLoaded => [ResultStatus.loaded, ResultStatus.loadedCached].contains(resultStatus);

  ItemState({
    required this.resultStatus,
    this.item,
  });

  dynamic copyWith() => this;
}

abstract class ItemFilterableState<TSearchModel, TItem> extends ItemState<TItem> {
  TSearchModel searchModel;

  ItemFilterableState({
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
