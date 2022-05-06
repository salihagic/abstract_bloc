import 'package:abstract_bloc/abstract_bloc.dart';

abstract class AbstractItemState<TItem> {
  ResultStatus resultStatus;
  TItem? item;

  AbstractItemState({
    required this.resultStatus,
    required this.item,
  });

  dynamic copyWith() => this;
}

abstract class AbstractItemFilterableState<TSearchModel, TItem>
    extends AbstractItemState<TItem> {
  TSearchModel searchModel;

  AbstractItemFilterableState({
    required ResultStatus resultStatus,
    required this.searchModel,
    required TItem item,
  }) : super(
          resultStatus: resultStatus,
          item: item,
        );

  @override
  dynamic copyWith() => this;
}
