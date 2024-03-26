import 'package:abstract_bloc/abstract_bloc.dart';

abstract class AbstractListState<TListItem> implements CopyWith {
  ResultStatus resultStatus;
  GridResult<TListItem> result;

  List<TListItem> get items => result.items;

  bool get isLoaded =>
      [ResultStatus.loaded, ResultStatus.loadedCached].contains(resultStatus);

  AbstractListState({
    required this.resultStatus,
    required this.result,
  });

  dynamic copyWith() => this;
}

abstract class AbstractListFilterableState<TSearchModel, TListItem>
    extends AbstractListState<TListItem> {
  TSearchModel searchModel;

  AbstractListFilterableState({
    required ResultStatus resultStatus,
    required this.searchModel,
    required GridResult<TListItem> result,
  }) : super(
          resultStatus: resultStatus,
          result: result,
        );

  @override
  dynamic copyWith() => this;
}

abstract class AbstractListFilterablePaginatedState<
    TSearchModel extends Pagination,
    TListItem> extends AbstractListFilterableState<TSearchModel, TListItem> {
  AbstractListFilterablePaginatedState({
    required ResultStatus resultStatus,
    required TSearchModel searchModel,
    required GridResult<TListItem> result,
  }) : super(
          resultStatus: resultStatus,
          searchModel: searchModel,
          result: result,
        );

  @override
  dynamic copyWith() => this;
}
