import 'package:flutter/material.dart';

class EmployeeDashboard extends StatelessWidget {
  const EmployeeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("My Dashboard"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Track your attendance and work statistics",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.4,
              children: const [
                _StatCard(title: "Days Present", value: "22"),
                _StatCard(title: "Days Absent", value: "1", color: Colors.red),
                _StatCard(title: "Avg Hours", value: "8.5"),
                _StatCard(title: "Attendance Rate", value: "95.6%"),
              ],
            ),

            const SizedBox(height: 20),

            _SectionTitle("Recent Attendance"),

            const SizedBox(height: 10),

            const _AttendanceTable(),

            const SizedBox(height: 20),

            const _MonthCard(),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E293B),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _AttendanceTable extends StatelessWidget {
  const _AttendanceTable();

  @override
  Widget build(BuildContext context) {
    final data = [
      ["2026-02-01", "08:45", "05:30", "8.75h", "Present"],
      ["2026-01-31", "08:50", "05:25", "8.58h", "Present"],
      ["2026-01-30", "08:35", "05:40", "9.08h", "Present"],
      ["2026-01-28", "09:10", "05:45", "8.58h", "Late"],
    ];

    return Card(
      color: const Color(0xFF1E293B),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: data.map((row) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(row[0], style: const TextStyle(color: Colors.white70)),
                  Text(row[1], style: const TextStyle(color: Colors.white70)),
                  Text(row[2], style: const TextStyle(color: Colors.white70)),
                  Text(row[3], style: const TextStyle(color: Colors.white70)),
                  Text(
                    row[4],
                    style: TextStyle(
                      color: row[4] == "Late" ? Colors.orange : Colors.green,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E293B),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const _SectionTitle("This Month"),

            const SizedBox(height: 10),

            _progress("Attendance", 0.956),
            _progress("Punctuality", 0.783),

            const SizedBox(height: 10),

            const Divider(color: Colors.grey),

            const SizedBox(height: 10),

            const Text("Total Work Hours",
                style: TextStyle(color: Colors.grey)),
            const Text("186.5h",
                style: TextStyle(color: Colors.white, fontSize: 18)),

            const SizedBox(height: 10),

            const Text("Days Worked",
                style: TextStyle(color: Colors.grey)),
            const Text("22 days",
                style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  static Widget _progress(String label, double value) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70)),
            Text("${(value * 100).toStringAsFixed(1)}%",
                style: const TextStyle(color: Colors.white)),
          ],
        ),
        const SizedBox(height: 5),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey,
          color: Colors.blue,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
