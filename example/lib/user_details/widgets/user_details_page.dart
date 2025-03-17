import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:example/models/user_details_search_model.dart';
import 'package:example/repositories/users_repository.dart';
import 'package:example/user_details/bloc/user_details_bloc.dart';
import 'package:example/user_details/bloc/user_details_event.dart';
import 'package:example/user_details/bloc/user_details_state.dart';
import 'package:flutter/material.dart';

class UserDetailsPage extends StatelessWidget {
  final int id;

  const UserDetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User details page')),
      body: BlocProvider(
        create:
            (context) => UserDetailsBloc(
              usersRepository: context.read<IUsersRepository>(),
            ),
        child: AbstractItemBuilder<UserDetailsBloc, UserDetailsState>(
          onInit:
              (context) => context.read<UserDetailsBloc>().add(
                UserDetailsLoadEvent(
                  searchModel: UserDetailsSearchModel(id: id),
                ),
              ),
          builder: (context, userDetailsState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        flex: 1,
                        child: Text(
                          'Name:',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          userDetailsState.item?.name ?? '',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        flex: 1,
                        child: Text(
                          'Email:',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          userDetailsState.item?.email ?? '',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        flex: 1,
                        child: Text(
                          'Gender:',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          userDetailsState.item?.gender ?? '',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        flex: 1,
                        child: Text(
                          'Status:',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          userDetailsState.item?.status ?? '',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
