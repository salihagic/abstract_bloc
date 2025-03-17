import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:example/models/user.dart';
import 'package:example/models/users_search_model.dart';

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
