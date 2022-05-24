abstract class AbstractFormEvent {}

class AbstractFormInitEvent<TSearchModel> extends AbstractFormEvent {
  TSearchModel? searchModel;

  AbstractFormInitEvent({this.searchModel});
}
