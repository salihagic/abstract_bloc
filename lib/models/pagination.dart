import 'package:abstract_bloc/models/base_pagination.dart';
import 'package:abstract_bloc/models/grid_result.dart';

class Pagination implements BasePagination {
  late int skip; // The number of items to skip for pagination
  late int take; // The number of items to take (retrieve) per page
  late int
      offset; // An offset used in special cases to offset number of first records if they were added locally through another channel other than standard fetch from API
  late String
      cursor; // A cursor for pagination, used in some APIs to fetch the next set of results

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
    cursor = '';
    offset = 0;
    reset(); // Initialize skip and take to the configured values
  }

  /// Resets the pagination values to their initial state.
  @override
  void reset() {
    skip = _initialSkip;
    take = _initialTake;
    offset = 0;
  }

  /// Increments the skip value by the number of items to take.
  @override
  void increment() => skip += take;

  /// Decrements the skip value by the number of items to take, ensuring it doesn't go negative.
  @override
  void decrement() {
    if (skip - take >= 0) {
      skip -= take;
    } else {
      skip = 0; // Prevent skip from becoming negative
    }
  }

  @override
  void update(GridResult gridResult) {}

  /// Converts the current pagination state to a JSON format.
  @override
  Map<String, dynamic> toJson() => configuration.toJson(this);

  /// Configuration for pagination settings, can be modified globally.
  static PaginationConfiguration configuration = PaginationConfiguration(
    initialPage: 1,
    pageSize: 10,
    toJson: (pagination) => {
      'page': pagination.page,
      'pageSize': pagination.take,
      'offset': pagination.offset,
    },
  );
}

/// A class representing pagination configuration options.
class PaginationConfiguration {
  final int initialPage; // The initial page value (default is 1)
  final int pageSize; // The size of each page (default is 10)

  // Function to convert the pagination state to JSON format
  final Map<String, dynamic> Function(Pagination pagination) toJson;

  const PaginationConfiguration({
    this.initialPage = 1,
    this.pageSize = 10,
    required this.toJson,
  });
}
