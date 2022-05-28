//Base model validator with default implementations of some common methods
abstract class ModelValidator {
  //Primarily used when you want to disable submit button
  bool validate(model) => true;
  List<String> messages(model) => [];
  String message(model, [String messagePrefix = '- ']) =>
      messagePrefix + messages(model).join('\n$messagePrefix');
}
