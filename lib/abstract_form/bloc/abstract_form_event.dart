abstract class AbstractFormEvent {}

class AbstractFormInitEvent extends AbstractFormEvent {
  dynamic model;

  AbstractFormInitEvent({this.model});
}

class AbstractFormUpdateEvent<TModel> extends AbstractFormEvent {
  TModel? model;

  AbstractFormUpdateEvent({this.model});
}

class AbstractFormSubmitEvent extends AbstractFormEvent {
  final bool preserve;

  AbstractFormSubmitEvent({this.preserve = true});
}
