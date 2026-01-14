import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:example/models/user.dart';
import 'package:example/models/users_search_model.dart';

/// State class for the users list.
///
/// Extends [AbstractListFilterablePaginatedState] which provides:
/// - `resultStatus` - Current loading status (loading, loaded, error, loadedCached)
/// - `searchModel` - Filter/pagination parameters
/// - `result` - GridResult containing items and pagination metadata
/// - `items` - Convenience getter for result.items
/// - `hasMoreItems` - Whether more pages are available
///
/// The state must implement [copyWith] for immutable state updates.
class UsersState
    extends AbstractListFilterablePaginatedState<UsersSearchModel, User> {
  UsersState({
    required super.resultStatus,
    required super.searchModel,
    required super.result,
  });

  @override
  UsersState copyWith({
    ResultStatus? resultStatus,
    UsersSearchModel? searchModel,
    GridResult<User>? result,
  }) => UsersState(
    resultStatus: resultStatus ?? this.resultStatus,
    searchModel: searchModel ?? this.searchModel,
    result: result ?? this.result,
  );
}
