import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:example/models/user_details_search_model.dart';

/// Event to load user details.
///
/// Requires a [searchModel] containing the user ID to fetch.
///
/// Dispatched when:
/// - The user details page first mounts
/// - User taps retry on error state
class UserDetailsLoadEvent
    extends AbstractItemLoadEvent<UserDetailsSearchModel> {
  UserDetailsLoadEvent({required UserDetailsSearchModel searchModel})
    : super(searchModel: searchModel);
}
