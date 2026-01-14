import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:example/models/user_details_search_model.dart';
import 'package:example/repositories/users_repository.dart';
import 'package:example/user_details/bloc/user_details_state.dart';

/// BLoC for loading a single user's details.
///
/// This demonstrates [AbstractItemBloc] usage for loading individual items.
/// Unlike [AbstractListBloc] which manages lists, this handles single items
/// commonly used for detail pages.
///
/// Features:
/// - Cache-first loading via [resolveStreamData]
/// - Automatic error/loading state handling
/// - Search model support for passing parameters (e.g., user ID)
class UserDetailsBloc extends AbstractItemBloc<UserDetailsState> {
  final IUsersRepository usersRepository;

  UserDetailsBloc({required this.usersRepository}) : super(_initialState());

  static UserDetailsState _initialState() => UserDetailsState(
    resultStatus: ResultStatus.loading,
    searchModel: UserDetailsSearchModel(),
  );

  /// Fetches user details using cache-first strategy.
  ///
  /// The stream will emit:
  /// 1. Cached data first (if available) with [ResultStatus.loadedCached]
  /// 2. Fresh network data with [ResultStatus.loaded]
  @override
  Stream<Result> resolveStreamData() =>
      usersRepository.getDetails(state.searchModel);

  // Alternative: Use resolveData() for network-only fetching
  // @override
  // Future<Result> resolveData() =>
  //     usersRepository.getDetailsOnlyNetwork(state.searchModel);
}
