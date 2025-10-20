import 'package:abstract_bloc/models/base_pagination.dart';
import 'package:abstract_bloc/models/grid_result.dart';

class CursorPagination implements BasePagination {
  late String previousCursor; // The cursor for the previous page
  late String nextCursor; // The cursor for the next page
  late String cursor;

  CursorPagination({
    this.previousCursor = '',
    this.nextCursor = '',
    this.cursor = '',
  }) {
    reset();
  }

  @override
  void reset() {
    cursor = '';
  }

  @override
  Map<String, dynamic> toJson() => configuration.toJson(this);

  static CursorPaginationConfiguration configuration =
      CursorPaginationConfiguration(
        toJson: (cursorPagination) => {
          if (cursorPagination.cursor.isNotEmpty)
            'cursor': cursorPagination.cursor,
        },
      );

  @override
  void decrement() {
    cursor = previousCursor;
  }

  @override
  void increment() {
    cursor = nextCursor;
  }

  @override
  void update(GridResult gridResult) {
    previousCursor = gridResult.previousCursor ?? '';
    nextCursor = gridResult.nextCursor ?? '';
  }
}

class CursorPaginationConfiguration {
  final Map<String, dynamic> Function(CursorPagination pagination) toJson;

  const CursorPaginationConfiguration({required this.toJson});
}
