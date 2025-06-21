import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/login_page.dart';
import '../scaffolds/user_scaffold.dart';

class StartupService {
  static Future<Widget> getStartPage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return UserScaffold();
    } else {
      return LoginPage();
    }
  }
}
