import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:example/models/users_search_model.dart';

/// Event to load or reload the users list.
///
/// Dispatched when:
/// - The widget first mounts (initial load)
/// - User applies new filters
/// - User taps retry on error state
///
/// Optionally accepts a [searchModel] to apply filters.
class UsersLoadEvent extends AbstractListLoadEvent<UsersSearchModel> {
  UsersLoadEvent({super.searchModel});
}

// Additional events you might add:
//
// class UsersRefreshEvent extends AbstractListRefreshEvent {}
// class UsersLoadMoreEvent extends AbstractListLoadMoreEvent {}
