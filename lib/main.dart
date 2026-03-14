import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _currentUser;

  void _login(String username) {
    setState(() => _currentUser = username);
  }

  void _logout() {
    setState(() => _currentUser = null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Lost & Found',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _currentUser == null
          ? LoginScreen(onLogin: _login)
          : HomeScreen(currentUser: _currentUser!, onLogout: _logout),
    );
  }
}
