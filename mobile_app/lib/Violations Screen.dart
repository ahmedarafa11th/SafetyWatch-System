import 'package:flutter/material.dart';

class ViolationsScreen extends StatelessWidget {
  final logs = [
    "Violence - Camera 3",
    "Restricted Access - Camera 8",
    "Unusual Activity - Camera 7",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Violation Logs")),
      body: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, i) {
          return ListTile(
            leading: const Icon(Icons.report),
            title: Text(logs[i]),
          );
        },
      ),
    );
  }
}
