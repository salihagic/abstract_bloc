import 'package:abstract_bloc/abstract_bloc.dart';

abstract class AbstractListState<TListItem> {
  ResultStatus resultStatus;
  List<TListItem> items;
  List<TListItem> cachedItems;

  bool get hasItems => items.isNotEmpty;
  bool get isLoaded =>
      [ResultStatus.loaded, ResultStatus.loadedCached].contains(resultStatus);

  AbstractListState({
    required this.resultStatus,
    required this.items,
    required this.cachedItems,
  });

  dynamic copyWith() => this;
}

abstract class AbstractListFilterableState<TSearchModel, TListItem>
    extends AbstractListState<TListItem> {
  TSearchModel searchModel;

  AbstractListFilterableState({
    required ResultStatus resultStatus,
    required this.searchModel,
    required List<TListItem> items,
    required List<TListItem> cachedItems,
  }) : super(
          resultStatus: resultStatus,
          items: items,
          cachedItems: cachedItems,
        );

  @override
  dynamic copyWith() => this;
}

abstract class AbstractListFilterablePaginatedState<TSearchModel, TListItem>
    extends AbstractListFilterableState<TSearchModel, TListItem> {
  bool hasMoreData;

  AbstractListFilterablePaginatedState({
    required ResultStatus resultStatus,
    required TSearchModel searchModel,
    required List<TListItem> items,
    required List<TListItem> cachedItems,
    this.hasMoreData = true,
  }) : super(
          resultStatus: resultStatus,
          searchModel: searchModel,
          items: items,
          cachedItems: cachedItems,
        );

  @override
  dynamic copyWith() => this;
}
