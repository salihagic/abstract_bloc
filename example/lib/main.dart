import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:example/repositories/users_repository.dart';
import 'package:example/users/widgets/users_list.dart';
import 'package:flutter/material.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RestApiClient.initFlutter();

  final restApiClient = RestApiClient(
    options: RestApiClientOptions(
      baseUrl: 'https://gorest.co.in/public/v2/',
      cacheEnabled: true,
    ),
  );
  await restApiClient.init();
  restApiClient.setContentType(Headers.jsonContentType);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IRestApiClient>(
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
            //This is the default implementation, you can provide your own or just ignore this parameter
            abstractItemErrorBuilder: (onInit) => Center(
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
            abstractItemNoDataBuilder: (onInit) => Center(
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
            abstractListErrorBuilder: (onInit) => Center(
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
            abstractListNoDataBuilder: (onInit) => Center(
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
            child: child!,
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
