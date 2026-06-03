import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/admin_shell.dart';
import 'screens/employee_shell.dart';

void main() {
  runApp(const ProviderScope(child: SafetyWatchApp()));
}

class SafetyWatchApp extends StatefulWidget {
  const SafetyWatchApp({super.key});

  @override
  State<SafetyWatchApp> createState() => _SafetyWatchAppState();
}

class _SafetyWatchAppState extends State<SafetyWatchApp> {
  ThemeMode themeMode = ThemeMode.dark;

  void toggleTheme() {
    setState(() {
      themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafetyWatch',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(onToggleTheme: toggleTheme),
        '/login': (context) => LoginScreen(onToggleTheme: toggleTheme),
        '/signup': (context) => SignupScreen(onToggleTheme: toggleTheme),
        '/admin': (context) => AdminShell(onToggleTheme: toggleTheme),
        '/employee': (context) => EmployeeShell(onToggleTheme: toggleTheme),
      },
    );
  }
}
