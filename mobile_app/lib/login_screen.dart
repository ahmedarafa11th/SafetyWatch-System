import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const LoginScreen({super.key, required this.onToggleTheme});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String role = "employee";

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void login() {
    if (role == "admin") {
      Navigator.pushReplacementNamed(context, '/admin');
    } else {
      Navigator.pushReplacementNamed(context, '/employee');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "SafetyWatch Login",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text("Employee"),
                  selected: role == "employee",
                  onSelected: (_) => setState(() => role = "employee"),
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text("Admin"),
                  selected: role == "admin",
                  onSelected: (_) => setState(() => role = "admin"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            ElevatedButton(onPressed: login, child: const Text("Login")),
          ],
        ),
      ),
    );
  }
}
