import 'package:abstract_bloc/abstract_bloc.dart';

class UsersSearchModel extends Pagination {
  @override
  Map<String, dynamic> toMap() {
    return {
      'page': super.page,
    };
  }
}
