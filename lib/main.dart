import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/logo_page.dart';
import 'services/startup_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cultural Heritage App',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: FutureBuilder<Widget>(
        future: StartupService.getStartPage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LogoPage(); // Show splash while checking login
          } else if (snapshot.hasData) {
            return snapshot.data!;
          } else {
            return LogoPage(); // fallback
          }
        },
      ),
    );
  }
}
