/// Extension methods for nullable lists of type T.
extension AbstractBlocListNullableExtensions<T> on List<T>? {
  /// Checks if the list is null or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Checks if the list is not null and not empty.
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// Returns the count of elements in the list, or 0 if the list is null.
  int get count => this?.length ?? 0;
}

/// Extension methods for non-nullable lists of type T.
extension AbstractBlocListExtensions<T> on List<T> {
  /// Adds an element to the list if the specified condition is true.
  /// Optionally, a callback can be executed if the element is added.
  void addIf(bool condition, T element, [Function(T)? callbackIfTrue]) {
    if (condition) {
      add(element);
      callbackIfTrue?.call(element);
    }
  }

  /// Toggles the presence of an element in the list based on an optional test function.
  /// Returns -1 if the element was removed, and 1 if it was added.
  int toggle(T element, [bool Function(T element)? test]) {
    final alreadyAdded =
        test != null ? firstOrDefault(test) != null : contains(element);

    if (alreadyAdded) {
      test != null ? removeWhere(test) : remove(element);
    } else {
      add(element);
    }

    return alreadyAdded ? -1 : 1;
  }

  /// Returns the first element in the list that satisfies the optional test function.
  /// If the test function is not provided, it returns the first element or null.
  T? firstOrDefault([bool Function(T element)? test]) {
    try {
      return test != null ? firstWhere(test) : first;
    } catch (e) {
      return null; // Returns null if no element is found or an error occurs.
    }
  }

  /// Removes the last [amount] of items from the list.
  void removeLastItems(int amount) {
    final end = length;
    final start = end - amount;

    if (amount > 0 && start < end) {
      removeRange(start >= 0 ? start : 0, end);
    }
  }
}
