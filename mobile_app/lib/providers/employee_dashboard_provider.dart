import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../core/network/api_constants.dart';
import '../models/attendance_record.dart';

class EmployeeDashboardState {
  final AttendanceStats stats;
  final List<AttendanceRecord> recentRecords;
  final bool isLoading;
  final String? error;

  const EmployeeDashboardState({
    this.stats = const AttendanceStats(),
    this.recentRecords = const [],
    this.isLoading = true,
    this.error,
  });

  int get attendanceRate {
    final total = stats.daysPresent + stats.daysLate + stats.daysAbsent;
    if (total == 0) return 0;
    return ((stats.daysPresent + stats.daysLate) / total * 100).round();
  }

  EmployeeDashboardState copyWith({
    AttendanceStats? stats,
    List<AttendanceRecord>? recentRecords,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return EmployeeDashboardState(
      stats: stats ?? this.stats,
      recentRecords: recentRecords ?? this.recentRecords,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class EmployeeDashboardNotifier extends Notifier<EmployeeDashboardState> {
  @override
  EmployeeDashboardState build() => const EmployeeDashboardState();

  DioClient get _dio => ref.read(dioProvider);

  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dio.get(ApiConstants.employeeDashboard);
      final data = response.data['data'] ?? response.data;

      final stats = data['stats'] != null
          ? AttendanceStats.fromJson(data['stats'])
          : const AttendanceStats();

      final List<dynamic> recordsList = data['recent_attendance'] ?? [];
      final records = recordsList
          .take(5)
          .map((e) => AttendanceRecord.fromJson(e))
          .toList();

      state = EmployeeDashboardState(
        stats: stats,
        recentRecords: records,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load dashboard.');
    }
  }
}

final employeeDashboardProvider =
    NotifierProvider<EmployeeDashboardNotifier, EmployeeDashboardState>(
        EmployeeDashboardNotifier.new);
