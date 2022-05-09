import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:example/models/user_details_search_model.dart';
import 'package:example/repositories/users_repository.dart';
import 'package:example/user_details/bloc/user_details_state.dart';

class UserDetailsBloc extends AbstractItemBloc<UserDetailsState> {
  final IUsersRepository usersRepository;

  UserDetailsBloc({
    required this.usersRepository,
  }) : super(_initialState());

  static UserDetailsState _initialState() => UserDetailsState(
        resultStatus: ResultStatus.loading,
        searchModel: UserDetailsSearchModel(),
      );

  // Example for loading cached and then network data
  // @override
  // Stream<Result> resolveStreamData() => usersRepository.getDetails(state.searchModel);

  // Example for loading only network data
  @override
  Future<Result> resolveData() =>
      usersRepository.getDetailsOnlyNetwrok(state.searchModel);
}
