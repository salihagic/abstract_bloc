import 'package:abstract_bloc/abstract_bloc.dart';

/// Search/filter model for the users list.
///
/// Extends [Pagination] to include pagination parameters automatically.
/// You can add custom filter fields here (e.g., name search, status filter).
///
/// The [toJson] method from [Pagination] is used to serialize
/// the parameters for API requests.
///
/// Example with custom filters:
/// ```dart
/// class UsersSearchModel extends Pagination {
///   final String? nameFilter;
///   final String? statusFilter;
///
///   UsersSearchModel({this.nameFilter, this.statusFilter});
///
///   @override
///   Map<String, dynamic> toJson() => {
///     ...super.toJson(),
///     if (nameFilter != null) 'name': nameFilter,
///     if (statusFilter != null) 'status': statusFilter,
///   };
/// }
/// ```
class UsersSearchModel extends Pagination {}
