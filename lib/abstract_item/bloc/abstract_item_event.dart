abstract class AbstractItemEvent {}

class AbstractItemLoadEvent<TSearchModel> extends AbstractItemEvent {
  TSearchModel? searchModel;

  AbstractItemLoadEvent({this.searchModel});
}
