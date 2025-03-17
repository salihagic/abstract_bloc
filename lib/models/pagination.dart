/// A class representing pagination logic for data retrieval.
class Pagination {
  late int skip; // The number of items to skip for pagination
  late int take; // The number of items to take (retrieve) per page

  /// Calculate the current page based on skip and take values.
  int get page => (skip ~/ take) + configuration.initialPage;

  // Internal state for resetting pagination
  late int _initialSkip;
  late int _initialTake;

  /// Constructor for creating a Pagination object.
  Pagination({
    int? skip,
    int? take,
  }) {
    _initialSkip = skip ?? 0;
    _initialTake = take ?? configuration.pageSize;
    reset(); // Initialize skip and take to the configured values
  }

  /// Resets the pagination values to their initial state.
  void reset() {
    skip = _initialSkip;
    take = _initialTake;
  }

  /// Increments the skip value by the number of items to take.
  void increment() => skip += take;

  /// Decrements the skip value by the number of items to take, ensuring it doesn't go negative.
  void decrement() {
    if (skip - take >= 0) {
      skip -= take;
    } else {
      skip = 0; // Prevent skip from becoming negative
    }
  }

  /// Converts the current pagination state to a JSON format.
  Map<String, dynamic> toJson() => configuration.toJson(page, take);

  /// Configuration for pagination settings, can be modified globally.
  static PaginationConfiguration configuration = PaginationConfiguration(
    initialPage: 1,
    pageSize: 10,
    toJson: (page, pageSize) => {
      'page': page,
      'pageSize': pageSize,
    },
  );
}

/// A class representing pagination configuration options.
class PaginationConfiguration {
  final int initialPage; // The initial page value (default is 1)
  final int pageSize; // The size of each page (default is 10)

  // Function to convert the pagination state to JSON format
  final Map<String, dynamic> Function(int page, int pageSize) toJson;

  const PaginationConfiguration({
    this.initialPage = 1,
    this.pageSize = 10,
    required this.toJson,
  });
}
