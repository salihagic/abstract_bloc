import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:example/models/user_details_search_model.dart';

class UserDetailsLoadEvent
    extends AbstractItemLoadEvent<UserDetailsSearchModel> {
  UserDetailsLoadEvent({required UserDetailsSearchModel searchModel})
      : super(searchModel: searchModel);
}
