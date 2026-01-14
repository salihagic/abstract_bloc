import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:example/models/user_details_search_model.dart';
import 'package:example/repositories/users_repository.dart';
import 'package:example/user_details/bloc/user_details_bloc.dart';
import 'package:example/user_details/bloc/user_details_event.dart';
import 'package:example/user_details/bloc/user_details_state.dart';
import 'package:flutter/material.dart';

/// Page displaying detailed user information.
///
/// Demonstrates [AbstractItemBuilder] which provides:
/// - Automatic loading state handling
/// - Error state with retry button
/// - Cached data indicator when showing cached data
///
/// The page uses the built-in `provider` parameter to create the [UserDetailsBloc],
/// eliminating the need for a separate [BlocProvider] wrapper.
class UserDetailsPage extends StatelessWidget {
  final int id;

  const UserDetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Details'), centerTitle: true),
      body: AbstractItemBuilder<UserDetailsBloc, UserDetailsState>(
        // Built-in provider - creates the BLoC automatically
        provider:
            (context) => UserDetailsBloc(
              usersRepository: context.read<IUsersRepository>(),
            ),

        // Load the user details when the widget is first built
        onInit:
            (context) => context.read<UserDetailsBloc>().add(
              UserDetailsLoadEvent(searchModel: UserDetailsSearchModel(id: id)),
            ),

        // Build the UI when data is loaded
        builder: (context, state) {
          final user = state.item;
          if (user == null) {
            return const SizedBox.shrink();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // User avatar
                CircleAvatar(
                  radius: 48,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // User name
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        user.status == 'active'
                            ? Colors.green.shade100
                            : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    user.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          user.status == 'active'
                              ? Colors.green.shade800
                              : Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Detail cards
                _DetailCard(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: user.email,
                ),
                const SizedBox(height: 12),
                _DetailCard(
                  icon: Icons.person_outline,
                  label: 'Gender',
                  value:
                      user.gender.isNotEmpty
                          ? '${user.gender[0].toUpperCase()}${user.gender.substring(1)}'
                          : '-',
                ),
                const SizedBox(height: 12),
                _DetailCard(
                  icon: Icons.tag,
                  label: 'User ID',
                  value: user.id.toString(),
                ),
              ],
            ),
          );
        },

        // Optional: Override the global error/loading builders for this page
        // loaderBuilder: (context) => const CustomLoader(),
        // errorBuilder: (context, onRetry) => CustomError(onRetry: onRetry),
        // noDataBuilder: (context, onRetry) => CustomEmpty(onRetry: onRetry),
      ),
    );
  }
}

/// A card displaying a single detail field.
class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(value, style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
