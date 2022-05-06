extension ListNullableExtensions<T> on List<T>? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;
  int get count => this == null ? 0 : this!.length;
}

extension ListExtensions<T> on List<T> {
  void addIf(bool condition, T element, [Function(T)? callbackIfTrue]) {
    if (condition) {
      add(element);
      if (callbackIfTrue != null) {
        callbackIfTrue(element);
      }
    }
  }

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

  T? firstOrDefault([bool Function(T element)? test]) {
    if (test != null) {
      try {
        return firstWhere(test);
      } catch (e) {
        return null;
      }
    } else {
      try {
        return firstWhere((T element) => true);
      } catch (e) {
        return null;
      }
    }
  }

  void removeLastItems(int amount) {
    final end = count;
    final start = end - amount;

    removeRange(start >= 0 ? start : 0, end);
  }
}
