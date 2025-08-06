import 'package:flutter/material.dart';
import 'package:careercheckr/constants/colors.dart';
import 'package:careercheckr/screens/dashboard_screen.dart';
import 'package:careercheckr/screens/profile_screen.dart';
import 'package:careercheckr/screens/detector_screen.dart';
import 'package:careercheckr/screens/history_screen.dart';
import 'package:careercheckr/screens/tips_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    DashboardScreen(),
    ProfileScreen(),
    DetectorScreen(),
    HistoryScreen(),
    TipsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Detector'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'Tips'),
        ],
      ),
    );
  }
}