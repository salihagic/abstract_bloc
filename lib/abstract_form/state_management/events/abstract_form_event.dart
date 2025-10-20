/// A base abstract class for form-related events.
/// This class serves as a parent for all form events, such as initialization,
/// updates, and submissions.
abstract class AbstractFormEvent {}

/// An event representing the initialization of a form.
/// This event can carry an optional model to initialize the form.
class AbstractFormInitEvent extends AbstractFormEvent {
  dynamic model;

  /// Creates an [AbstractFormInitEvent].
  /// - [model]: Optional data to initialize the form.
  AbstractFormInitEvent({this.model});
}

/// An event representing an update to the form's model.
/// This event is generic and can carry a model of any type [TModel].
class AbstractFormUpdateEvent<TModel> extends AbstractFormEvent {
  TModel? model;

  /// Creates an [AbstractFormUpdateEvent].
  /// - [model]: Optional updated model data.
  AbstractFormUpdateEvent({this.model});
}

/// An event representing the submission of a form.
/// This event is generic and can carry a model of any type [TModel].
class AbstractFormSubmitEvent<TModel> extends AbstractFormEvent {
  TModel? model;

  /// Creates an [AbstractFormSubmitEvent].
  /// - [model]: Optional model data to submit.
  AbstractFormSubmitEvent({this.model});
}
