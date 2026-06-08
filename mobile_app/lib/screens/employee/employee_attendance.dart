import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/app_colors.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/loading_shimmer.dart';
import '../../providers/attendance_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_constants.dart';
import '../../core/storage/secure_storage_service.dart';
class EmployeeAttendanceScreen extends ConsumerStatefulWidget {
  const EmployeeAttendanceScreen({super.key});

  @override
  ConsumerState<EmployeeAttendanceScreen> createState() =>
      _EmployeeAttendanceScreenState();
}

class _EmployeeAttendanceScreenState
    extends ConsumerState<EmployeeAttendanceScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(employeeAttendanceProvider.notifier).fetch());
  }

  void _showMonthPicker() {
    final state = ref.read(employeeAttendanceProvider);
    String tempMonth = state.filterMonth ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Filter by Month"),
        content: TextField(
          decoration: const InputDecoration(
            labelText: "Month (YYYY-MM)",
            hintText: "e.g. 2026-06",
          ),
          controller: TextEditingController(text: tempMonth),
          onChanged: (v) => tempMonth = v,
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(employeeAttendanceProvider.notifier).clearFilter();
              Navigator.pop(ctx);
            },
            child: const Text("Clear"),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(employeeAttendanceProvider.notifier)
                  .setFilter(tempMonth);
              Navigator.pop(ctx);
            },
            child: const Text("Apply"),
          ),
        ],
      ),
    );
  }

  void _exportCsv() {
    final csv = ref
        .read(employeeAttendanceProvider.notifier)
        .generateCsv(includeEmployeeName: false);
    Share.share(csv, subject: 'my-attendance-logs.csv');
  }

  String _formatMonthLabel(String? val) {
    if (val == null || val.isEmpty) return 'Filter by Date';
    try {
      final parts = val.split('-');
      final months = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
      ];
      return '${months[int.parse(parts[1]) - 1]} ${parts[0]}';
    } catch (_) {
      return val;
    }
  }

  Future<void> _faceScan(String actionType) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 70,
    );

    if (image == null) return;

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );

      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(image.path, filename: 'frame.jpg'),
      });

      // 1. Face Recognition API
      final recRes = await dio.post(ApiConstants.runpodFaceApi, data: formData);
      if (recRes.statusCode == 200 && recRes.data['recognized'] == true) {
        final employeeCode = recRes.data['employee_code'];
        final token = await ref.read(secureStorageProvider).getToken() ?? '';

        // 2. Laravel API
        final logRes = await dio.post(
          '${ApiConstants.baseUrl}/api/admin/attendance/log-via-face',
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          ),
          data: {'employee_code': employeeCode, 'action': actionType},
        );

        Navigator.pop(context); // hide loading
        if (logRes.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(logRes.data['message'])),
          );
          ref.read(employeeAttendanceProvider.notifier).fetch();
        }
      } else {
        Navigator.pop(context); // hide loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Face not recognized.')),
        );
      }
    } catch (e) {
      Navigator.pop(context); // hide loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Could not connect to AI server. Please check your connection or try again later.',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final state = ref.watch(employeeAttendanceProvider);

    return RefreshIndicator(
      onRefresh: () => ref
          .read(employeeAttendanceProvider.notifier)
          .fetch(month: state.filterMonth),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text("My Attendance Logs",
                style:
                    TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("View your complete attendance history",
                style: TextStyle(color: secondaryText, fontSize: 14)),
            const SizedBox(height: 16),

            // Filter + Export buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showMonthPicker,
                    icon: const Icon(Icons.calendar_month, size: 18),
                    label: Text(
                      _formatMonthLabel(state.filterMonth),
                      style: const TextStyle(fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      side: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _faceScan('check_in'),
                  icon: const Icon(Icons.login, size: 18),
                  label: const Text("Check In",
                      style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _faceScan('check_out'),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text("Check Out",
                      style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: state.records.isEmpty ? null : _exportCsv,
                  icon: Icon(Icons.download, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  tooltip: 'Export CSV',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Stats
            Row(
              children: [
                Expanded(
                    child: StatCard(
                        value: '${state.stats.daysPresent}',
                        label: "Days Present",
                        icon: Icons.calendar_today,
                        color: AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(
                    child: StatCard(
                        value: '${state.stats.daysLate}',
                        label: "Days Late",
                        icon: Icons.schedule,
                        color: AppColors.warning)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: StatCard(
                        value: '${state.stats.daysAbsent}',
                        label: "Days Absent",
                        icon: Icons.event_busy,
                        color: AppColors.error)),
                const SizedBox(width: 12),
                Expanded(
                    child: StatCard(
                        value: state.stats.totalHours,
                        label: "Total Hours",
                        icon: Icons.access_time,
                        color: AppColors.success)),
              ],
            ),
            const SizedBox(height: 24),

            // Records list (card-based, replacing DataTable)
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: ListShimmer(itemCount: 5),
              )
            else if (state.records.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text("No attendance records found.",
                      style:
                          TextStyle(color: secondaryText, fontSize: 14)),
                ),
              )
            else
              AnimationLimiter(
                child: Column(
                  children: state.records.asMap().entries.map((entry) {
                    final index = entry.key;
                    final record = entry.value;
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(record.date,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(
                                '${record.checkInFormatted} → ${record.checkOutFormatted}',
                                style: TextStyle(
                                    color: secondaryText, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(record.hoursFormatted,
                                style: TextStyle(
                                    color: secondaryText, fontSize: 12)),
                            const SizedBox(height: 4),
                            StatusBadge(text: record.statusDisplay),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
               ),
              ),
             );
            }).toList(),
            ),
          ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
