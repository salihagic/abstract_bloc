import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:example/models/users_search_model.dart';

class UsersLoadEvent extends AbstractListLoadEvent<UsersSearchModel> {
  UsersLoadEvent({super.searchModel});
}
