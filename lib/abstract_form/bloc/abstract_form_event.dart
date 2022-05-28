abstract class AbstractFormEvent {}

class AbstractFormInitEvent<TSearchModel> extends AbstractFormEvent {
  TSearchModel? searchModel;

  AbstractFormInitEvent({this.searchModel});
}

class AbstractFormUpdateEvent<TModel> extends AbstractFormEvent {
  TModel? model;

  AbstractFormUpdateEvent({this.model});
}

class AbstractFormSubmitEvent extends AbstractFormEvent {}
