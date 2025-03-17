/// A base abstract class for model validation.
/// This class provides default implementations for common validation methods,
/// such as validating a model, retrieving validation messages, and formatting messages.
abstract class ModelValidator {
  /// Validates the given model.
  /// Returns `true` if the model is valid, otherwise `false`.
  /// By default, this method always returns `true`.
  bool validate(model) => true;

  /// Retrieves a list of validation messages for the given model.
  /// By default, this method returns an empty list.
  List<String> messages(model) => [];

  /// Formats the validation messages into a single string.
  /// - [model]: The model to validate.
  /// - [messagePrefix]: A prefix to add to each message (default is '- ').
  /// Returns a formatted string of validation messages.
  String message(model, [String messagePrefix = '- ']) =>
      messagePrefix + messages(model).join('\n$messagePrefix');
}
