import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:example/models/user.dart';
import 'package:example/models/user_details.dart';
import 'package:example/models/user_details_search_model.dart';
import 'package:example/models/users_search_model.dart';

/// Repository interface for user-related operations.
///
/// Defines the contract for fetching users and user details.
/// Using an interface allows for easy mocking in tests.
abstract class IUsersRepository {
  /// Fetches a paginated list of users.
  ///
  /// Returns a [Stream] for cache-first strategy:
  /// 1. First emits cached data (if available)
  /// 2. Then emits fresh network data
  Stream<Result<GridResult<User>>> get(UsersSearchModel model);

  /// Fetches details for a specific user.
  ///
  /// Returns a [Stream] for cache-first strategy.
  Stream<Result<UserDetails>> getDetails(UserDetailsSearchModel model);

  /// Fetches user details from network only (no cache).
  ///
  /// Use this when you always need fresh data.
  Future<Result<UserDetails>> getDetailsOnlyNetwork(
    UserDetailsSearchModel model,
  );
}

/// Implementation of [IUsersRepository] using [RestApiClient].
///
/// Demonstrates how to use RestApiClient with abstract_bloc:
/// - `getStreamed()` for cache-first strategy (returns Stream)
/// - `get()` for network-only requests (returns Future)
class UsersRepository implements IUsersRepository {
  final RestApiClient restApiClient;

  UsersRepository({required this.restApiClient});

  @override
  Stream<Result<GridResult<User>>> get(UsersSearchModel model) {
    // getStreamed returns a Stream that emits cached data first,
    // then network data. This enables the cache-first UX pattern.
    return restApiClient.getStreamed(
      '/users',
      queryParameters: model.toJson(),
      onSuccess:
          (data) => GridResult(
            items: data.map<User>((map) => User.fromMap(map)).toList(),
            // Note: In a real app, you'd parse hasMoreItems from API response
            // hasMoreItems: data.length >= model.take,
          ),
    );
  }

  @override
  Stream<Result<UserDetails>> getDetails(UserDetailsSearchModel model) {
    // Cache-first: shows cached user details while loading fresh data
    return restApiClient.getStreamed(
      '/users/${model.id}',
      onSuccess: (data) => UserDetails.fromMap(data),
    );
  }

  @override
  Future<Result<UserDetails>> getDetailsOnlyNetwork(
    UserDetailsSearchModel model,
  ) {
    // Network-only: always fetches fresh data, no caching
    return restApiClient.get(
      '/users/${model.id}',
      onSuccess: (data) => UserDetails.fromMap(data),
    );
  }
}
