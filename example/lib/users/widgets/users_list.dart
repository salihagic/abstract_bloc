import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:example/repositories/users_repository.dart';
import 'package:example/users/bloc/users_bloc.dart';
import 'package:example/users/bloc/users_event.dart';
import 'package:example/users/bloc/users_state.dart';
import 'package:example/users/widgets/user_card.dart';
import 'package:flutter/material.dart';

class UsersList extends StatelessWidget {
  const UsersList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UsersBloc(
        usersRepository: context.read<IUsersRepository>(),
      ),
      child: AbstractListConsumer<UsersBloc, UsersState>(
        onInit: (context) => context.read<UsersBloc>().add(UsersLoadEvent()),
        itemBuilder: (usersState, index) =>
            UserCard(user: usersState.items[index]),
      ),
    );
  }
}
