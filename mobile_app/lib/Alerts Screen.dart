import 'package:flutter/material.dart';

class AlertsScreen extends StatelessWidget {
  final List<Map<String, String>> alerts = [
    {
      "title": "Violence Detected",
      "desc": "Aggressive behavior detected in warehouse area",
      "camera": "Camera 3 - Warehouse",
      "time": "2026-02-01 14:35",
      "confidence": "92%",
      "status": "Critical"
    },
    {
      "title": "Suspicious Activity",
      "desc": "Person near restricted area",
      "camera": "Camera 8 - Server Room",
      "time": "2026-02-01 11:20",
      "confidence": "85%",
      "status": "High"
    },
    {
      "title": "Unusual Movement",
      "desc": "Rapid movement detected",
      "camera": "Camera 7 - Parking",
      "time": "2026-01-31 09:45",
      "confidence": "78%",
      "status": "Medium"
    },
  ];

  Color getColor(String status) {
    switch (status) {
      case "Critical":
        return Colors.red;
      case "High":
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Security Alerts"),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text("Mark All Read", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat("Active", "2", Colors.red),
                _stat("Critical", "1", Colors.orange),
                _stat("Resolved", "2", Colors.green),
                _stat("Confidence", "90%", Colors.blue),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final a = alerts[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(a["title"]!,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: getColor(a["status"]!),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                a["status"]!,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Text(a["desc"]!),
                        SizedBox(height: 10),
                        Text("📷 ${a["camera"]}"),
                        Text("⏱ ${a["time"]}"),
                        Text("🎯 Confidence: ${a["confidence"]}"),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              child: Text("Resolve"),
                            ),
                            SizedBox(width: 10),
                            OutlinedButton(
                              onPressed: () {},
                              child: Text("Dismiss"),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _stat(String title, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(title),
      ],
    );
  }
}
