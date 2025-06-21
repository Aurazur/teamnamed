import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../pages/dashboard_page.dart';
import '../pages/settings_page.dart';
import '../pages/map_page.dart';

class UserScaffold extends StatefulWidget {
  const UserScaffold({super.key});

  @override
  State<UserScaffold> createState() => _UserScaffoldState();
}

class _UserScaffoldState extends State<UserScaffold> {
  int _selectedIndex = 0;
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        _username = doc['username'];
      });
    }
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return "Home";
      case 1:
        return "Map";
      case 2:
        return "Settings";
      default:
        return "Dashboard";
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return DashboardPage();
      case 1:
        return const MapPage();
      case 2:
        return SettingsPage(username: _username ?? '');
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Ensure no black shows through
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(_getTitle()), // Optional dynamic title
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(child: _getBody()), // Wrap to avoid system insets
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
