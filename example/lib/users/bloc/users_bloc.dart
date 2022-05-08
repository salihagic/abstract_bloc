import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:example/models/users_search_model.dart';
import 'package:example/repositories/users_repository.dart';
import 'package:example/users/bloc/users_state.dart';

class UsersBloc extends AbstractListBloc<UsersState> {
  final IUsersRepository usersRepository;

  UsersBloc({
    required this.usersRepository,
  }) : super(_initialState());

  @override
  UsersState initialState() => _initialState();

  static UsersState _initialState() => UsersState(
        resultStatus: ResultStatus.loading,
        searchModel: UsersSearchModel(),
        items: [],
        cachedItems: [],
      );

  @override
  Stream<Result> resolveStreamData() => usersRepository.get(state.searchModel);
}
