import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:example/models/user_details.dart';
import 'package:example/models/user_details_search_model.dart';

class UserDetailsState
    extends AbstractItemFilterableState<UserDetailsSearchModel, UserDetails> {
  UserDetailsState({
    required ResultStatus resultStatus,
    required UserDetailsSearchModel searchModel,
    UserDetails? item,
  }) : super(
          resultStatus: resultStatus,
          searchModel: searchModel,
          item: item,
        );

  @override
  UserDetailsState copyWith({
    ResultStatus? resultStatus,
    UserDetailsSearchModel? searchModel,
    UserDetails? item,
  }) =>
      UserDetailsState(
        resultStatus: resultStatus ?? this.resultStatus,
        searchModel: searchModel ?? this.searchModel,
        item: item ?? this.item,
      );
}
