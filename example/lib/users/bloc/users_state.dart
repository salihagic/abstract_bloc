import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:example/models/user.dart';
import 'package:example/models/users_search_model.dart';

class UsersState
    extends AbstractListFilterablePaginatedState<UsersSearchModel, User> {
  UsersState({
    required ResultStatus resultStatus,
    required UsersSearchModel searchModel,
    required List<User> items,
    required List<User> cachedItems,
    bool hasMoreData = true,
  }) : super(
          resultStatus: resultStatus,
          searchModel: searchModel,
          items: items,
          cachedItems: cachedItems,
          hasMoreData: hasMoreData,
        );

  @override
  UsersState copyWith({
    ResultStatus? resultStatus,
    UsersSearchModel? searchModel,
    List<User>? items,
    List<User>? cachedItems,
    bool? hasMoreData,
  }) =>
      UsersState(
        resultStatus: resultStatus ?? this.resultStatus,
        searchModel: searchModel ?? this.searchModel,
        items: items ?? this.items,
        cachedItems: cachedItems ?? this.cachedItems,
        hasMoreData: hasMoreData ?? this.hasMoreData,
      );
}
