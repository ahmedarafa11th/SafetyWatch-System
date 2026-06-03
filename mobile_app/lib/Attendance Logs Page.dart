import 'package:flutter/material.dart';

class AttendanceLogsPage extends StatefulWidget {
  const AttendanceLogsPage({super.key});

  @override
  State<AttendanceLogsPage> createState() => _AttendanceLogsPageState();
}

class _AttendanceLogsPageState extends State<AttendanceLogsPage> {
  final List<Map<String, dynamic>> rows = [
    {
      'date': '2026-02-01',
      'checkIn': '08:45 AM',
      'checkOut': '05:30 PM',
      'hours': '8.75h',
      'status': 'Present',
    },
    {
      'date': '2026-01-31',
      'checkIn': '08:50 AM',
      'checkOut': '05:25 PM',
      'hours': '8.58h',
      'status': 'Present',
    },
    {
      'date': '2026-01-28',
      'checkIn': '09:10 AM',
      'checkOut': '05:45 PM',
      'hours': '8.58h',
      'status': 'Late',
    },
    {
      'date': '2026-01-25',
      'checkIn': '-',
      'checkOut': '-',
      'hours': '0h',
      'status': 'Absent',
    },
    {
      'date': '2026-01-21',
      'checkIn': '09:05 AM',
      'checkOut': '05:50 PM',
      'hours': '8.75h',
      'status': 'Late',
    },
  ];

  String? selectedMonth;

  List<Map<String, dynamic>> get filteredRows {
    if (selectedMonth == null) return rows;
    return rows.where((row) => row['date'].startsWith(selectedMonth!)).toList();
  }

  Future<void> pickMonth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      helpText: 'Select Month',
    );

    if (picked != null) {
      setState(() {
        selectedMonth =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}';
      });
    }
  }

  Color statusColor(String status) {
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

  Widget statCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
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
        title: const Text('My Attendance Logs'),
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
                          'Export feature can be added using excel package',
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
                statCard('22', 'Days Present', Colors.blue),
                statCard('2', 'Days Late', Colors.orange),
              ],
            ),
            Row(
              children: [
                statCard('1', 'Days Absent', Colors.red),
                statCard('186.5h', 'Total Hours', Colors.green),
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
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row['date'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Check In: ${row['checkIn']}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            'Check Out: ${row['checkOut']}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            'Total Hours: ${row['hours']}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor(
                                row['status'],
                              ).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              row['status'],
                              style: TextStyle(
                                color: statusColor(row['status']),
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
