import 'package:flutter/material.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        title: const Text("Admin Dashboard"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Overview of your workplace safety system",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  statCard("145", "Total Employees", Colors.blue),
                  statCard("128", "Present Today", Colors.green),
                ],
              ),
              Row(
                children: [
                  statCard("12", "Active Cameras", Colors.cyan),
                  statCard("3", "Security Alerts", Colors.red),
                ],
              ),

              const SizedBox(height: 20),

              sectionTitle("Recent Attendance", Icons.access_time),
              const SizedBox(height: 10),

              cardContainer([
                attendanceRow("Ahmed Hassan", "08:45 AM", "On Time", Colors.green),
                attendanceRow("Sara Mohamed", "08:52 AM", "On Time", Colors.green),
                attendanceRow("Omar Ali", "09:15 AM", "Late", Colors.orange),
                attendanceRow("Fatima Ibrahim", "08:30 AM", "On Time", Colors.green),
              ]),

              const SizedBox(height: 20),

              sectionTitle("Recent Alerts", Icons.warning_amber_rounded),
              const SizedBox(height: 10),

              cardContainer([
                alertRow("Violence Detected", "Camera 3 - Warehouse\n2 hours ago", Colors.red),
                alertRow("Unusual Activity", "Camera 7 - Parking\n5 hours ago", Colors.orange),
                alertRow("Camera Offline", "Camera 5 - Lobby\n1 day ago", Colors.yellow),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget statCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget cardContainer(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget attendanceRow(String name, String time, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(color: Colors.white)),
              Text(time, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(status, style: TextStyle(color: color)),
          )
        ],
      ),
    );
  }

  Widget alertRow(String title, String sub, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white)),
                Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
