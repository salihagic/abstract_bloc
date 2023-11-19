import 'dart:developer';

import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:abstract_bloc/widgets/_all.dart';
import 'package:example/repositories/users_repository.dart';
import 'package:example/users/widgets/users_list.dart';
import 'package:flutter/material.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RestApiClient.initFlutter();

  final restApiClient = RestApiClientImpl(
    options: RestApiClientOptions(
      baseUrl: 'https://gorest.co.in/public/v2/',
      cacheEnabled: true,
    ),
    interceptors: [
      InterceptorsWrapper(
        onRequest: (options, handler) {
          log('Logging before request');

          return handler.next(options);
        },
        onResponse: (response, handler) {
          log('Logging on response');

          return handler.next(response);
        },
        onError: (DioException e, handler) {
          log('Logging on error');

          return handler.next(e);
        },
      ),
    ],
  );
  await restApiClient.init();
  restApiClient.setContentType(Headers.jsonContentType);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<RestApiClient>(
          create: (_) => restApiClient,
        ),
        RepositoryProvider<IUsersRepository>(
          create: (_) => UsersRepository(restApiClient: restApiClient),
        ),
      ],
      child: MaterialApp(
        title: 'Abstract Bloc Example',
        builder: (context, child) {
          //We can configure error and no-data container globally
          //so we don't have to specify it every time or have to
          //use the default one
          return AbstractConfiguration(
            loaderBuilder: (context) => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            ),
            smallLoaderBuilder: (context) => ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Container(
                color: Colors.white.withOpacity(0.5),
                padding: const EdgeInsets.all(14.0),
                child: const SizedBox(
                  height: 12,
                  width: 12,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ),
              ),
            ),
            cachedDataWarningIconBuilder: (context, onTap) => InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(50),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  color: Colors.white.withOpacity(0.5),
                  padding: const EdgeInsets.all(8.0),
                  child: const Icon(
                    Icons.info_outline,
                    color: Color(0xFFC42A03),
                  ),
                ),
              ),
            ),
            cachedDataWarningDialogBuilder: (context, onReload) => InfoDialog(
              showCancelButton: true,
              onApplyText: 'Reload',
              onCancel: () {
                Navigator.of(context).pop();
              },
              onApply: () {
                onReload?.call(context);
                Navigator.of(context).pop();
              },
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Showing cached data',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'There was an error, please try again',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            //This is the default implementation, you can provide your own or just ignore this parameter
            abstractItemErrorBuilder: (context, onInit) => Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('An error occured, please try again'),
                  const SizedBox(height: 15),
                  TextButton(
                    //This is used to re-fetch the data in case
                    //an error happens
                    onPressed: () => onInit.call(),
                    child: const Text(
                      'Reload',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
            //This is the default implementation, you can provide your own or just ignore this parameter
            abstractItemNoDataBuilder: (context, onInit) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('There is no data'),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () => onInit.call(),
                    child: const Text(
                      'Reload',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
            //This is the default implementation, you can provide your own or just ignore this parameter
            abstractListErrorBuilder: (context, onInit) => Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('An error occured, please try again'),
                  const SizedBox(height: 15),
                  TextButton(
                    //This is used to re-fetch the data in case
                    //an error happens
                    onPressed: () => onInit.call(),
                    child: const Text(
                      'Reload',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
            //This is the default implementation, you can provide your own or just ignore this parameter
            abstractListNoDataBuilder: (context, onInit) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('There is no data'),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () => onInit.call(),
                    child: const Text(
                      'Reload',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
            paginationConfiguration: PaginationConfiguration(
              page: 1,
              pageSize: 10,
              toJson: (page, pageSize) => {
                'page': page,
              },
            ),
            child: RefreshConfiguration(
              headerBuilder: () => const ClassicHeader(
                refreshingIcon: Loader.sm(),
                completeText: 'Successfully refreshed',
                refreshingText: 'Refreshing',
                releaseText: 'Release to refresh',
                idleText: 'Pull down to refresh',
              ),
              footerBuilder: () => ClassicFooter(
                loadingIcon: const Loader.sm(),
                canLoadingText: 'Release to load more',
                loadingText: 'Loading',
                idleText: 'Pull to load more',
                idleIcon: Container(),
              ),
              headerTriggerDistance: 80.0,
              springDescription: const SpringDescription(
                  stiffness: 170, damping: 16, mass: 1.9),
              maxOverScrollExtent: 100,
              maxUnderScrollExtent: 0,
              enableScrollWhenRefreshCompleted: true,
              enableLoadingWhenFailed: true,
              hideFooterWhenNotFull: false,
              enableBallisticLoad: true,
              child: child!,
            ),
          );
        },
        home: const HomePage(),
      ),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Abstract Bloc Example'),
      ),
      body: const UsersList(),
    );
  }
}
