import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tripmanager/Utils/constants.dart';
import 'package:tripmanager/View/trips_screen.dart';
import 'package:tripmanager/View/profile_screen.dart';

class DriverBottomNavBar extends StatefulWidget {
  @override
  _DriverBottomNavBarState createState() => _DriverBottomNavBarState();
}

class _DriverBottomNavBarState extends State<DriverBottomNavBar> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    TripsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryColor,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.local_shipping,
              ),
              label: "Settings"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
