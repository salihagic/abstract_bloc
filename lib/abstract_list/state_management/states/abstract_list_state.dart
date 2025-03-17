import 'package:abstract_bloc/abstract_bloc.dart';

abstract class AbstractListState<TListItem> implements CopyWith {
  ResultStatus resultStatus;
  GridResult<TListItem> result;

  List<TListItem> get items => result.items;

  bool get isLoadedAny =>
      [ResultStatus.loaded, ResultStatus.loadedCached].contains(resultStatus);
  bool get isLoadedNetwork => ResultStatus.loaded == resultStatus;
  bool get isLoadedCached => ResultStatus.loadedCached == resultStatus;

  AbstractListState({
    required this.resultStatus,
    required this.result,
  });

  @override
  dynamic copyWith();
}

abstract class AbstractListFilterableState<TSearchModel, TListItem>
    extends AbstractListState<TListItem> {
  TSearchModel searchModel;

  AbstractListFilterableState({
    required super.resultStatus,
    required this.searchModel,
    required super.result,
  });

  @override
  dynamic copyWith();
}

abstract class AbstractListFilterablePaginatedState<
    TSearchModel extends Pagination,
    TListItem> extends AbstractListFilterableState<TSearchModel, TListItem> {
  AbstractListFilterablePaginatedState({
    required super.resultStatus,
    required super.searchModel,
    required super.result,
  });

  @override
  dynamic copyWith();
}
