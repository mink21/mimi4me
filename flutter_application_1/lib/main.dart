import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tabs.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const List<String> _pageName = ["Home", "Settings", "Search"];
  static const List<Widget> _pageList = [
    HomeTab(pannelColor: Colors.cyan, title: 'Home'),
    SettingTab(pannelColor: Colors.cyan, title: 'Setting'),
    SearchTab(pannelColor: Colors.cyan, title: 'Search'),
  ];
  static const List<BottomNavigationBarItem> _tabList = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: 'Setting',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: 'Search',
    ),
  ];

  int _selectedIndex = 0;

  final key = 'current_tab';

  _read() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getInt(key) ?? 0;
    setState(() {
      _selectedIndex = val;
    });
  }

  void _save(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final value = index;
    prefs.setInt(key, value);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _save(index);
    });
  }

  @override
  void initState() {
    super.initState();
    _read();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageName[_selectedIndex]),
      ),
      body: _pageList[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _tabList,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
