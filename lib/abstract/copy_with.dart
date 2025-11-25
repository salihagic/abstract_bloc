/// A base abstract class for enabling the `copyWith` pattern.
/// Classes that implement this interface must provide a `copyWith` method,
/// which is commonly used to create a new instance of the class with modified properties.
abstract class CopyWith<T> {
  /// Creates a new instance of the class with updated properties.
  /// This method should return a new object with the desired changes applied.
  T copyWith();
}
