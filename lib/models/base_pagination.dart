import 'package:abstract_bloc/abstract_bloc.dart';

/// A class representing pagination logic for data retrieval.
abstract class BasePagination {
  void reset();
  void increment();
  void decrement();

  /// Jumps directly to the page identified by [page].
  ///
  /// Offset-based implementations interpret [page] as a page index using the
  /// pagination configuration's `initialPage` (e.g. 0-indexed or 1-indexed).
  /// Cursor-based implementations that cannot random-access pages may
  /// implement this as a no-op or restrict it to the cursors they already
  /// know about.
  void goToPage(int page);
  void update(GridResult gridResult);
  Map<String, dynamic> toJson();
}
