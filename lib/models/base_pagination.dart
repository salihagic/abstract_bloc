import 'package:abstract_bloc/abstract_bloc.dart';

/// A class representing pagination logic for data retrieval.
abstract class BasePagination {
  void reset();
  void increment();
  void decrement();
  void update(GridResult gridResult);
  Map<String, dynamic> toJson();
}
