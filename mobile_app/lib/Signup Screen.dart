import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(labelText: "Full Name"),
            ),
            const TextField(decoration: InputDecoration(labelText: "Email")),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: "Confirm Password"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Create Account"),
            ),
          ],
        ),
      ),
    );
  }
}
