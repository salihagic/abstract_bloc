abstract class AbstractFormEvent {}

class AbstractFormInitEvent extends AbstractFormEvent {
  dynamic model;

  AbstractFormInitEvent({this.model});
}

class AbstractFormUpdateEvent<TModel> extends AbstractFormEvent {
  TModel? model;

  AbstractFormUpdateEvent({this.model});
}

class AbstractFormSubmitEvent<TModel> extends AbstractFormEvent {
  TModel? model;

  AbstractFormSubmitEvent({
    this.model,
  });
}
