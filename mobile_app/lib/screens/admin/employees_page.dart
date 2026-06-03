import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../widgets/status_badge.dart';

class EmployeesPageScreen extends StatefulWidget {
  const EmployeesPageScreen({super.key});

  @override
  State<EmployeesPageScreen> createState() => _EmployeesPageScreenState();
}

class _EmployeesPageScreenState extends State<EmployeesPageScreen> {
  String search = "";

  List<Map<String, String>> employees = [
    {"name": "Ahmed Hassan", "dept": "AI & Deep Learning", "pos": "AI Engineer", "status": "Active", "date": "01/15/2024"},
    {"name": "Sara Mohamed", "dept": "Software Engineering", "pos": "Frontend Dev", "status": "Active", "date": "11/01/2023"},
    {"name": "Omar Ali", "dept": "Data Science", "pos": "Data Analyst", "status": "Inactive", "date": "05/20/2022"},
    {"name": "Fatima Ibrahim", "dept": "HR & Operations", "pos": "HR Manager", "status": "Active", "date": "08/10/2021"},
    {"name": "Mohamed Khaled", "dept": "AI & Deep Learning", "pos": "ML Researcher", "status": "On Leave", "date": "03/12/2023"},
  ];

  List<Map<String, String>> get filtered {
    if (search.isEmpty) return employees;
    final q = search.toLowerCase();
    return employees.where((e) =>
      e["name"]!.toLowerCase().contains(q) ||
      e["dept"]!.toLowerCase().contains(q) ||
      e["pos"]!.toLowerCase().contains(q)
    ).toList();
  }

  void _showAddEditDialog({Map<String, String>? emp, int? index}) {
    final nameC = TextEditingController(text: emp?["name"] ?? "");
    final deptC = TextEditingController(text: emp?["dept"] ?? "");
    final posC = TextEditingController(text: emp?["pos"] ?? "");
    final dateC = TextEditingController(text: emp?["date"] ?? "");
    String status = emp?["status"] ?? "Active";

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(emp == null ? "Add Employee" : "Edit Employee"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameC, decoration: const InputDecoration(labelText: "Name")),
                const SizedBox(height: 12),
                TextField(controller: deptC, decoration: const InputDecoration(labelText: "Department")),
                const SizedBox(height: 12),
                TextField(controller: posC, decoration: const InputDecoration(labelText: "Position")),
                const SizedBox(height: 12),
                TextField(controller: dateC, decoration: const InputDecoration(labelText: "Join Date")),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(labelText: "Status"),
                  items: ["Active", "Inactive", "On Leave"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setDialogState(() => status = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                final newEmp = {"name": nameC.text, "dept": deptC.text, "pos": posC.text, "status": status, "date": dateC.text};
                setState(() {
                  if (emp == null) {
                    employees.insert(0, newEmp);
                  } else {
                    employees[index!] = newEmp;
                  }
                });
                Navigator.pop(ctx);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Employees", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("Manage staff, roles, and access levels", style: TextStyle(color: secondaryText, fontSize: 14)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddEditDialog(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Add Employee"),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search
          TextField(
            onChanged: (v) => setState(() => search = v),
            decoration: const InputDecoration(
              hintText: "Search employees...",
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 20),

          // Table
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 48,
                dataRowMinHeight: 56,
                dataRowMaxHeight: 56,
                columnSpacing: 20,
                horizontalMargin: 16,
                headingTextStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: secondaryText, letterSpacing: 0.5),
                dataTextStyle: TextStyle(fontSize: 13, color: isDark ? Colors.white : AppColors.lightTextPrimary),
                columns: const [
                  DataColumn(label: Text("EMPLOYEE NAME")),
                  DataColumn(label: Text("DEPARTMENT")),
                  DataColumn(label: Text("POSITION")),
                  DataColumn(label: Text("STATUS")),
                  DataColumn(label: Text("JOIN DATE")),
                  DataColumn(label: Text("ACTIONS")),
                ],
                rows: List.generate(filtered.length, (i) {
                  final e = filtered[i];
                  return DataRow(cells: [
                    DataCell(Text(e["name"]!, style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text(e["dept"]!)),
                    DataCell(Text(e["pos"]!)),
                    DataCell(StatusBadge(text: e["status"]!)),
                    DataCell(Text(e["date"]!)),
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                          onPressed: () => _showAddEditDialog(emp: e, index: employees.indexOf(e)),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.error.withAlpha(50)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            padding: EdgeInsets.zero,
                            onPressed: () => setState(() => employees.remove(e)),
                          ),
                        ),
                      ],
                    )),
                  ]);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
