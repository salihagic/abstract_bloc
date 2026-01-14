import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:example/repositories/users_repository.dart';
import 'package:example/users/bloc/users_bloc.dart';
import 'package:example/users/bloc/users_event.dart';
import 'package:example/users/bloc/users_state.dart';
import 'package:example/users/widgets/user_card.dart';
import 'package:flutter/material.dart';

/// Widget displaying a paginated list of users.
///
/// Demonstrates [AbstractListBuilder] which provides:
/// - Automatic loading state handling
/// - Pull-to-refresh support
/// - Infinite scroll pagination (load more on scroll)
/// - Error state with retry button
/// - Empty state handling
/// - Cached data indicator when showing cached data
///
/// The widget uses the built-in `provider` parameter to create the [UsersBloc],
/// eliminating the need for a separate [BlocProvider] wrapper.
class UsersList extends StatelessWidget {
  const UsersList({super.key});

  @override
  Widget build(BuildContext context) {
    return AbstractListBuilder<UsersBloc, UsersState>(
      // Built-in provider - creates the BLoC automatically
      provider:
          (context) =>
              UsersBloc(usersRepository: context.read<IUsersRepository>()),

      // Called when the widget is first built to trigger initial load
      onInit: (context) => context.read<UsersBloc>().add(UsersLoadEvent()),

      // Build each item in the list
      itemBuilder:
          (context, usersState, index) =>
              UserCard(user: usersState.items[index]),

      // Number of columns (1 = ListView, 2+ = GridView)
      columns: 1,

      // Optional: Custom header that scrolls with the list
      // header: const Padding(
      //   padding: EdgeInsets.all(16),
      //   child: Text('Users', style: TextStyle(fontSize: 24)),
      // ),

      // Optional: Fixed header that stays at the top
      // fixedHeader: true,

      // Optional: Custom padding
      // padding: const EdgeInsets.symmetric(horizontal: 8),

      // Optional: Custom separator between items
      // separatorBuilder: (context, index) => const Divider(height: 1),

      // Optional: Override the global error/empty/loading builders
      // loaderBuilder: (context) => const CustomLoader(),
      // errorBuilder: (context, onRetry) => CustomError(onRetry: onRetry),
      // noDataBuilder: (context, onRetry) => CustomEmpty(onRetry: onRetry),
    );
  }
}
