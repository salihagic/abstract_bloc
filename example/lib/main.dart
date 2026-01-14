import 'dart:developer';

import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:example/repositories/users_repository.dart';
import 'package:example/users/widgets/users_list.dart';
import 'package:flutter/material.dart';

/// Example application demonstrating the abstract_bloc package.
///
/// This example shows:
/// - Setting up RestApiClient with caching enabled
/// - Configuring AbstractConfiguration for global UI customization
/// - Using AbstractListBuilder for paginated lists with pull-to-refresh
/// - Using AbstractItemBuilder for detail pages with cache-first loading
///
/// Key features demonstrated:
/// - Automatic loading, error, and empty state handling
/// - Cache-first data strategy (shows cached data while loading fresh data)
/// - Custom UI builders for all states
/// - Pagination configuration
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RestApiClient.initFlutter();

  // Initialize the REST API client with caching enabled.
  // The cache allows showing previously loaded data when offline.
  final restApiClient = RestApiClientImpl(
    options: RestApiClientOptions(
      baseUrl: 'https://gorest.co.in/public/v2/',
      cacheEnabled: true, // Enable caching for offline support
    ),
    interceptors: [
      // Optional: Add logging interceptor for debugging
      InterceptorsWrapper(
        onRequest: (options, handler) {
          log('Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          log('Response: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          log('Error: ${e.message}');
          return handler.next(e);
        },
      ),
    ],
  );
  await restApiClient.init();
  restApiClient.setContentType(Headers.jsonContentType);

  runApp(
    // Provide repositories to the widget tree
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<RestApiClient>(create: (_) => restApiClient),
        RepositoryProvider<IUsersRepository>(
          create: (_) => UsersRepository(restApiClient: restApiClient),
        ),
      ],
      child: MaterialApp(
        title: 'Abstract Bloc Example',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        builder: (context, child) {
          // Configure abstract_bloc globally using AbstractConfiguration.
          // This allows you to customize the default widgets for loading,
          // error, empty states, and cached data indicators across your app.
          return AbstractConfiguration(
            // Main loading indicator used when data is being fetched
            loaderBuilder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),

            // Small loading indicator shown when cached data is displayed
            // and fresh data is being fetched in the background
            cachedDataLoaderBuilder: (context) => ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Container(
                color: Colors.white.withValues(alpha: 0.8),
                padding: const EdgeInsets.all(14.0),
                child: const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),

            // Icon shown when displaying cached data - tap to see more info
            cachedDataWarningIconBuilder: (context, onTap) => InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(50),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  color: Colors.white.withValues(alpha: 0.8),
                  padding: const EdgeInsets.all(8.0),
                  child: const Icon(
                    Icons.cloud_off,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
              ),
            ),

            // Dialog shown when user taps the cached data warning icon
            cachedDataWarningDialogBuilder: (context, onReload) => InfoDialog(
              showCancelButton: true,
              onApplyText: 'Reload',
              onCancel: () => Navigator.of(context).pop(),
              onApply: () {
                onReload?.call(context);
                Navigator.of(context).pop();
              },
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off, size: 48, color: Colors.orange),
                  SizedBox(height: 16),
                  Text(
                    'Showing Cached Data',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Unable to connect to the server. Displaying previously saved data.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Error widget for AbstractItemBuilder (single item pages)
            abstractItemErrorBuilder: (context, onRetry) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Something went wrong',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const Text('Please try again'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),

            // Empty state widget for AbstractItemBuilder
            abstractItemNoDataBuilder: (context, onRetry) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.inbox, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No Data Found',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            ),

            // Error widget for AbstractListBuilder (list pages)
            abstractListErrorBuilder: (context, onRetry) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load data',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const Text('Check your connection and try again'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),

            // Empty state widget for AbstractListBuilder
            abstractListNoDataBuilder: (context, onRetry) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.inbox, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No Users Found',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const Text('Pull down to refresh'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            ),

            // Configure pagination to match the gorest.co.in API format
            paginationConfiguration: PaginationConfiguration(
              initialPage: 1,
              pageSize: 10,
              toJson: (pagination) => {
                'page': pagination.page,
                'per_page': pagination.take,
              },
            ),

            child: child!,
          );
        },
        home: const HomePage(),
      ),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        centerTitle: true,
      ),
      body: const UsersList(),
    );
  }
}
