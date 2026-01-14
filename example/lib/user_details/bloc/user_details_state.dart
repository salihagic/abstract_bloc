import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:example/models/user_details.dart';
import 'package:example/models/user_details_search_model.dart';

/// State class for user details.
///
/// Extends [AbstractItemFilterableState] which provides:
/// - `resultStatus` - Current loading status (loading, loaded, error, loadedCached)
/// - `searchModel` - Parameters for fetching (contains user ID)
/// - `item` - The loaded user details (nullable until loaded)
///
/// The state must implement [copyWith] for immutable state updates.
class UserDetailsState
    extends AbstractItemFilterableState<UserDetailsSearchModel, UserDetails> {
  UserDetailsState({
    required super.resultStatus,
    required super.searchModel,
    super.item,
  });

  @override
  UserDetailsState copyWith({
    ResultStatus? resultStatus,
    UserDetailsSearchModel? searchModel,
    UserDetails? item,
  }) => UserDetailsState(
    resultStatus: resultStatus ?? this.resultStatus,
    searchModel: searchModel ?? this.searchModel,
    item: item ?? this.item,
  );
}
