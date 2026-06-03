import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/app_colors.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/loading_shimmer.dart';
import '../../providers/employees_provider.dart';
import '../../models/employee.dart';
import 'dart:async';

class EmployeesPageScreen extends ConsumerStatefulWidget {
  const EmployeesPageScreen({super.key});

  @override
  ConsumerState<EmployeesPageScreen> createState() => _EmployeesPageScreenState();
}

class _EmployeesPageScreenState extends ConsumerState<EmployeesPageScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(employeesProvider.notifier).fetch());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(employeesProvider.notifier).fetch(search: query);
    });
  }

  void _showAddEditDialog({Employee? emp}) {
    final form = emp != null
        ? EmployeeFormData.fromEmployee(emp)
        : EmployeeFormData();
    final isEdit = emp != null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final isSaving = ref.watch(employeesProvider).isSaving;
          return AlertDialog(
            title: Text(isEdit ? "Edit Employee" : "Add New Employee"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isEdit) ...[
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Email *",
                        hintText: "e.g. ahmed@safetywatch.com",
                        helperText: "Must be a registered account",
                        helperMaxLines: 2,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (v) => form.email = v,
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    initialValue: form.department,
                    decoration: const InputDecoration(
                      labelText: "Department *",
                      hintText: "e.g. Software Engineering",
                    ),
                    onChanged: (v) => form.department = v,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: form.position,
                    decoration: const InputDecoration(
                      labelText: "Position *",
                      hintText: "e.g. Backend Developer",
                    ),
                    onChanged: (v) => form.position = v,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: ValueKey(form.joinDate),
                    initialValue: form.joinDate,
                    decoration: const InputDecoration(
                      labelText: "Join Date *",
                      hintText: "YYYY-MM-DD",
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: ctx,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        final formatted = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                        form.joinDate = formatted;
                        setDialogState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: form.phone,
                    decoration: const InputDecoration(
                      labelText: "Phone",
                      hintText: "e.g. +20 1XX XXX XXXX",
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (v) => form.phone = v,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: form.status,
                    decoration: const InputDecoration(labelText: "Status *"),
                    items: const [
                      DropdownMenuItem(value: "active", child: Text("Active")),
                      DropdownMenuItem(value: "inactive", child: Text("Inactive")),
                      DropdownMenuItem(value: "on_leave", child: Text("On Leave")),
                    ],
                    onChanged: (v) => setDialogState(() => form.status = v!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        bool success;
                        if (isEdit) {
                          success = await ref
                              .read(employeesProvider.notifier)
                              .updateEmployee(emp.id, form);
                        } else {
                          success = await ref
                              .read(employeesProvider.notifier)
                              .addEmployee(form);
                        }
                        if (!ctx.mounted) return;
                        if (success) {
                          Navigator.pop(ctx);
                        } else {
                          final error = ref.read(employeesProvider).error;
                          if (error != null && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                child: Text(isSaving
                    ? "Saving..."
                    : (isEdit ? "Save Changes" : "Add Employee")),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(Employee emp) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Employee"),
        content: Text("Are you sure you want to delete ${emp.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success =
          await ref.read(employeesProvider.notifier).deleteEmployee(emp.id);
      if (!mounted) return;
      if (!success) {
        final error = ref.read(employeesProvider).error;
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final state = ref.watch(employeesProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(employeesProvider.notifier).fetch(
            search: _searchController.text,
          ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                      const Text("Employees",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("Manage staff, roles, and access levels",
                          style:
                              TextStyle(color: secondaryText, fontSize: 14)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddEditDialog(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add"),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: "Search employees...",
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),

            // Content
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: ListShimmer(itemCount: 4),
              )
            else if (state.employees.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    "No employees found.",
                    style: TextStyle(color: secondaryText, fontSize: 14),
                  ),
                ),
              )
            else
              AnimationLimiter(
                child: Column(
                  children: state.employees.asMap().entries.map((entry) {
                    final index = entry.key;
                    final emp = entry.value;
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: _employeeCard(emp, isDark, secondaryText),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _employeeCard(Employee emp, bool isDark, Color secondaryText) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withAlpha(30),
                child: Text(
                  emp.name.isNotEmpty ? emp.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(emp.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(emp.position,
                        style:
                            TextStyle(color: secondaryText, fontSize: 13)),
                  ],
                ),
              ),
              StatusBadge(text: emp.statusDisplay),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.business, size: 14, color: secondaryText),
              const SizedBox(width: 6),
              Text(emp.department,
                  style: TextStyle(color: secondaryText, fontSize: 13)),
              const Spacer(),
              Icon(Icons.calendar_today, size: 14, color: secondaryText),
              const SizedBox(width: 6),
              Text(emp.joinDate ?? '—',
                  style: TextStyle(color: secondaryText, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () => _showAddEditDialog(emp: emp),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary.withAlpha(80)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_outlined,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text("Edit",
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _confirmDelete(emp),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: AppColors.error.withAlpha(80)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.delete_outline,
                          size: 16, color: AppColors.error),
                      const SizedBox(width: 6),
                      const Text("Delete",
                          style: TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
