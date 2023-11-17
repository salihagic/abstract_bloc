import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:example/models/user.dart';
import 'package:example/models/user_details.dart';
import 'package:example/models/user_details_search_model.dart';
import 'package:example/models/users_search_model.dart';

abstract class IUsersRepository {
  Stream<Result<GridResult<User>>> get(UsersSearchModel model);
  Stream<Result<UserDetails>> getDetails(UserDetailsSearchModel model);
  Future<Result<UserDetails>> getDetailsOnlyNetwork(UserDetailsSearchModel model);
}

class UsersRepository implements IUsersRepository {
  final RestApiClient restApiClient;

  UsersRepository({required this.restApiClient});

  @override
  Stream<Result<GridResult<User>>> get(UsersSearchModel model) {
    return restApiClient.getStreamed(
      '/users',
      queryParameters: model.toJson(),
      parser: (data) => GridResult(
        items: data.map<User>((map) => User.fromMap(map)).toList(),
      ),
    );
  }

  // Example for loading cached and then network data
  @override
  Stream<Result<UserDetails>> getDetails(UserDetailsSearchModel model) {
    return restApiClient.getStreamed(
      '/users/${model.id}',
      parser: (data) => UserDetails.fromMap(data),
    );
  }

  // Example for loading only network data
  @override
  Future<Result<UserDetails>> getDetailsOnlyNetwork(UserDetailsSearchModel model) {
    return restApiClient.get(
      '/users/${model.id}',
      parser: (data) => UserDetails.fromMap(data),
    );
  }
}
