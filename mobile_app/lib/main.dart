import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/admin_shell.dart';
import 'screens/employee_shell.dart';
import 'providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    try {
      await FlutterDisplayMode.setHighRefreshRate();
    } catch (e) {
      // Ignore if not supported
    }
  }

  // Transparent status bar for edge-to-edge
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  runApp(const ProviderScope(child: SafetyWatchApp()));
}

class SafetyWatchApp extends ConsumerStatefulWidget {
  const SafetyWatchApp({super.key});

  @override
  ConsumerState<SafetyWatchApp> createState() => _SafetyWatchAppState();
}

class _SafetyWatchAppState extends ConsumerState<SafetyWatchApp> {
  ThemeMode themeMode = ThemeMode.light;
  bool? _hasSeenOnboarding;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Check onboarding flag and theme
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('has_seen_onboarding') ?? false;
    final isDark = prefs.getBool('is_dark_theme') ?? false;

    // Initialize auth from stored session
    await ref.read(authProvider.notifier).initialize();

    if (mounted) {
      setState(() {
        _hasSeenOnboarding = seen;
        themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      });
    }
  }

  void toggleTheme() async {
    final newMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setState(() {
      themeMode = newMode;
    });
    
    // Persist choice
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_theme', newMode == ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Show splash while loading
    if (_hasSeenOnboarding == null || !authState.isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SafetyWatch',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // Determine initial screen
    Widget homeWidget;
    if (authState.isAuthenticated) {
      homeWidget = authState.isAdmin 
          ? AdminShell(onToggleTheme: toggleTheme) 
          : EmployeeShell(onToggleTheme: toggleTheme);
    } else if (!_hasSeenOnboarding!) {
      homeWidget = OnboardingScreen(onToggleTheme: toggleTheme);
    } else {
      homeWidget = LoginScreen(onToggleTheme: toggleTheme);
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafetyWatch',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: homeWidget,
      routes: {
        'onboarding': (context) => OnboardingScreen(
              onToggleTheme: toggleTheme,
            ),
        'login': (context) => LoginScreen(onToggleTheme: toggleTheme),
        'signup': (context) => SignupScreen(onToggleTheme: toggleTheme),
        'admin': (context) => AdminShell(onToggleTheme: toggleTheme),
        'employee': (context) => EmployeeShell(onToggleTheme: toggleTheme),
      },
    );
  }
}
