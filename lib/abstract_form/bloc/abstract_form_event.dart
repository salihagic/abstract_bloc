abstract class AbstractFormEvent {}

class AbstractFormResetEvent extends AbstractFormEvent {}

class AbstractFormInitEvent<TSearchModel> extends AbstractFormEvent {
  TSearchModel? model;

  AbstractFormInitEvent({this.model});
}

class AbstractFormUpdateEvent<TModel> extends AbstractFormEvent {
  TModel? model;

  AbstractFormUpdateEvent({this.model});
}

class AbstractFormSubmitEvent extends AbstractFormEvent {}
