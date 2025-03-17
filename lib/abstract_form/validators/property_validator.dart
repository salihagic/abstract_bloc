/// A base abstract class for validating a specific property of a model.
/// This class is generic and can be used to validate properties of any type [T].
/// Subclasses must implement the `validate` method to provide custom validation logic.
abstract class PropertyValidator<T> {
  /// Validates the given property value.
  /// - [value]: The value of the property to validate.
  /// Returns a validation error message if the value is invalid, otherwise `null`.
  String? validate(T value) => null;
}
