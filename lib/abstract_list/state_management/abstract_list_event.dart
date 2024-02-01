abstract class AbstractListEvent {}

class AbstractListLoadEvent<TSearchModel> extends AbstractListEvent {
  TSearchModel? searchModel;

  AbstractListLoadEvent({this.searchModel});
}

class AbstractListRefreshEvent extends AbstractListEvent {}

class AbstractListLoadMoreEvent extends AbstractListEvent {}
