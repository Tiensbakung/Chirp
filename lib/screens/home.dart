import 'package:beamer/beamer.dart';
import 'package:chirp/screens/login.dart';
import 'package:chirp/screens/tweets.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final int index;
  const HomeScreen({Key? key, required this.index}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final _items = const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'Login'),
  ];

  @override
  void initState() {
    _index = widget.index;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          TweetListScreen(),
          TwitterLoginScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        items: _items,
        onTap: (index) {
          Beamer.of(context).update(
            configuration: RouteInformation(
              location: index == 0 ? '?tab=home' : '?tab=login',
            ),
            rebuild: false,
          );
          setState(() {
            _index = index;
          });
        },
      ),
    );
  }
}
