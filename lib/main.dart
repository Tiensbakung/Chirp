import 'package:beamer/beamer.dart';
import 'package:chirp/screens/home.dart';
import 'package:chirp/screens/users.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final routerDelegate = BeamerDelegate(
    locationBuilder: RoutesLocationBuilder(
      routes: {
        '/': (context, state, data) {
          final index = state.queryParameters['tab'] == 'login' ? 1 : 0;
          return HomeScreen(index: index);
        },
        '/users/:id': (context, state, data) {
          final id = state.pathParameters['id']!;
          return BeamPage(
            key: ValueKey('user:$id'),
            title: 'User $id',
            popToNamed: '/',
            type: BeamPageType.slideRightTransition,
            child: UserDetailsScreen(id: id),
          );
        }
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blueGrey,
      ),
      routerDelegate: routerDelegate,
      routeInformationParser: BeamerParser(),
      backButtonDispatcher: BeamerBackButtonDispatcher(
        delegate: routerDelegate,
      ),
    );
  }
}
