import 'package:flutter/material.dart';

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({super.key});

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  List<Map<String, dynamic>> employees = [
    {
      "name": "Ahmed Hassan",
      "dept": "AI & Deep Learning",
      "pos": "AI Engineer",
      "status": "Active",
      "date": "2024-01-15",
    },
    {
      "name": "Sara Mohamed",
      "dept": "Backend Development",
      "pos": "Backend Developer",
      "status": "Active",
      "date": "2024-02-01",
    },
    {
      "name": "Omar Ali",
      "dept": "Mobile Development",
      "pos": "Flutter Developer",
      "status": "Active",
      "date": "2024-01-20",
    },
    {
      "name": "Fatima Ibrahim",
      "dept": "UI/UX & Frontend",
      "pos": "Frontend Developer",
      "status": "On Leave",
      "date": "2024-02-10",
    },
  ];

  String search = "";

  Color statusColor(String status) {
    switch (status) {
      case "Active":
        return Colors.green;
      case "Inactive":
        return Colors.red;
      case "On Leave":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  List<Map<String, dynamic>> get filtered {
    return employees.where((e) {
      final q = search.toLowerCase();
      return e["name"].toLowerCase().contains(q) ||
          e["dept"].toLowerCase().contains(q) ||
          e["pos"].toLowerCase().contains(q);
    }).toList();
  }

  void addEmployeeDialog({Map<String, dynamic>? edit, int? index}) {
    final name = TextEditingController(text: edit?["name"] ?? "");
    final dept = TextEditingController(text: edit?["dept"] ?? "");
    final pos = TextEditingController(text: edit?["pos"] ?? "");
    final date = TextEditingController(text: edit?["date"] ?? "");
    String status = edit?["status"] ?? "Active";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          edit == null ? "Add Employee" : "Edit Employee",
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              textField(name, "Name"),
              textField(dept, "Department"),
              textField(pos, "Position"),
              textField(date, "Join Date"),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: status,
                dropdownColor: const Color(0xFF111827),
                items: ["Active", "Inactive", "On Leave"]
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(
                          s,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => status = v!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final emp = {
                "name": name.text,
                "dept": dept.text,
                "pos": pos.text,
                "status": status,
                "date": date.text,
              };

              setState(() {
                if (edit == null) {
                  employees.insert(0, emp);
                } else {
                  employees[index!] = emp;
                }
              });

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget textField(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: c,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF0F172A),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
        title: const Text("Employees"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addEmployeeDialog(),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              onChanged: (v) => setState(() => search = v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search employees...",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final e = filtered[i];
                  return Card(
                    color: const Color(0xFF1E293B),
                    child: ListTile(
                      title: Text(
                        e["name"],
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        "${e["dept"]} • ${e["pos"]}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor(e["status"]).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              e["status"],
                              style: TextStyle(
                                color: statusColor(e["status"]),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white70),
                            onPressed: () =>
                                addEmployeeDialog(edit: e, index: i),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () =>
                                setState(() => employees.removeAt(i)),
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
