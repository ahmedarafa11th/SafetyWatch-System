import 'package:flutter/material.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final List<Map<String, dynamic>> rows = [
    {
      'name': 'Ahmed Hassan',
      'date': '2026-02-01',
      'checkIn': '08:45 AM',
      'checkOut': '05:30 PM',
      'hours': '8.75h',
      'status': 'Present',
    },
    {
      'name': 'Sara Mohamed',
      'date': '2026-02-01',
      'checkIn': '08:52 AM',
      'checkOut': '05:45 PM',
      'hours': '8.88h',
      'status': 'Present',
    },
    {
      'name': 'Omar Ali',
      'date': '2026-02-01',
      'checkIn': '09:15 AM',
      'checkOut': '06:00 PM',
      'hours': '8.75h',
      'status': 'Late',
    },
    {
      'name': 'Fatima Ibrahim',
      'date': '2026-02-01',
      'checkIn': '08:30 AM',
      'checkOut': '05:15 PM',
      'hours': '8.75h',
      'status': 'Present',
    },
    {
      'name': 'Mohamed Khaled',
      'date': '2026-02-01',
      'checkIn': '08:00 AM',
      'checkOut': '04:30 PM',
      'hours': '8.5h',
      'status': 'Present',
    },
  ];

  String? selectedMonth;

  List<Map<String, dynamic>> get filteredRows {
    if (selectedMonth == null) return rows;
    return rows.where((row) => row['date'].startsWith(selectedMonth!)).toList();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Present':
        return Colors.green;
      case 'Late':
        return Colors.orange;
      case 'Absent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> pickMonth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      helpText: 'Filter by Date',
    );

    if (picked != null) {
      setState(() {
        selectedMonth =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}';
      });
    }
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
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        title: const Text('Attendance Logs'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: pickMonth,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(selectedMonth ?? 'Filter by Date'),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Export to Excel can be added using excel package',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Export'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                statCard('128', 'Present Today', Colors.blue),
                statCard('12', 'Late Today', Colors.orange),
              ],
            ),
            Row(
              children: [
                statCard('5', 'Absent Today', Colors.red),
                statCard('88.3%', 'Attendance Rate', Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredRows.length,
                itemBuilder: (context, index) {
                  final row = filteredRows[index];
                  return Card(
                    color: const Color(0xFF1E293B),
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row['name'],
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Date: ${row['date']}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            'Check In: ${row['checkIn']}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            'Check Out: ${row['checkOut']}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            'Hours: ${row['hours']}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: getStatusColor(
                                row['status'],
                              ).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              row['status'],
                              style: TextStyle(
                                color: getStatusColor(row['status']),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
