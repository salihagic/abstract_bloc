import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:example/models/users_search_model.dart';
import 'package:example/repositories/users_repository.dart';
import 'package:example/users/bloc/users_state.dart';
import 'package:example/models/user.dart';

/// BLoC for managing a paginated list of users.
///
/// This demonstrates AbstractListBloc usage with:
/// - Pagination support (load more on scroll)
/// - Cache-first strategy via [resolveStreamData]
/// - Search/filter model support
///
/// The BLoC inherits from [AbstractListBloc] which provides:
/// - `load()` - Load/reload data
/// - `refresh()` - Pull-to-refresh
/// - `loadMore()` - Load next page
/// - `update()` - Update search parameters
/// - `snapshot()`/`revert()` - Filter dialog pattern
class UsersBloc extends AbstractListBloc<UsersState> {
  final IUsersRepository usersRepository;

  UsersBloc({required this.usersRepository}) : super(_initialState());

  @override
  UsersState initialState() => _initialState();

  static UsersState _initialState() => UsersState(
    resultStatus: ResultStatus.loading,
    searchModel: UsersSearchModel(),
    result: GridResult<User>(),
  );

  /// Fetches users from the repository using cache-first strategy.
  ///
  /// The stream will emit:
  /// 1. Cached data first (if available) with [ResultStatus.loadedCached]
  /// 2. Fresh network data with [ResultStatus.loaded]
  ///
  /// This provides a smooth UX where users see cached data immediately
  /// while fresh data loads in the background.
  @override
  Stream<Result> resolveStreamData() => usersRepository.get(state.searchModel);

  // Alternative: Use resolveData() for network-only fetching
  // @override
  // Future<Result> resolveData() => usersRepository.getNetworkOnly(state.searchModel);
}
