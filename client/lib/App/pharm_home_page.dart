import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import "../Home/pharm_home_page_generator.dart";
import "../Profile/profile_page.dart";
import "../Authentication/login_page.dart";
import 'app.dart';

class PharmHomePage extends StatefulWidget {
  const PharmHomePage({super.key});

  @override
  _PharmHomePageState createState() => _PharmHomePageState();
}

class _PharmHomePageState extends State<PharmHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ProfilePage(),
  ];
  final List<String> _titles = ['Home', 'Profile'];

  void _handleLogout() async {
    try {
      // Clear user data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      // Reset the app state
      Provider.of<MyAppState>(context, listen: false).resetState();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Error during logout: $e');
      // Handle the error appropriately
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        shadowColor: Colors.grey.shade400, // Set the shadow color
        surfaceTintColor: Colors.white,

        // title: Image.asset(
        //   'lib/Resources/images/logo.png',
        //   fit: BoxFit.contain,
        //   height: 120,
        // ),

        centerTitle: true,
        title: Text(_titles[_currentIndex],
            style: const TextStyle(color: Colors.grey)),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 3) {
            _handleLogout();
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        selectedItemColor: const Color.fromARGB(255, 46, 125, 100),

        // selectedItemColor: const Color.fromARGB(
        // 255, 125, 167, 255), // Set the color for selected items
        unselectedItemColor: Colors.grey,
        type:
            BottomNavigationBarType.fixed, // Set the color for unselected items
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
      ),
    );
  }
}

class HomePage extends PharmHomePageGenerator {
  const HomePage({super.key});
}

class ProfilePage extends ProfilePageGenerator {
  const ProfilePage({super.key});
}
