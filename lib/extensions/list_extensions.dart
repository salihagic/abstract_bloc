/// Extension methods for nullable lists of type T.
extension AbstractBlocListNullableExtensions<T> on List<T>? {
  /// Checks if the list is null or empty.
  bool get abstractBlocListIsNullOrEmpty => this == null || this!.isEmpty;

  /// Checks if the list is not null and not empty.
  bool get abstractBlocListIsNotNullOrEmpty => !abstractBlocListIsNullOrEmpty;

  /// Returns the count of elements in the list, or 0 if the list is null.
  int get abstractBlocListCount => this?.length ?? 0;
}

/// Extension methods for non-nullable lists of type T.
extension AbstractBlocListExtensions<T> on List<T> {
  /// Removes the last [amount] of items from the list.
  void abstractBlocListRemoveLastItems(int amount) {
    final end = length;
    final start = end - amount;

    if (amount > 0 && start < end) {
      removeRange(start >= 0 ? start : 0, end);
    }
  }
}
