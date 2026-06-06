import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../core/network/api_constants.dart';
import '../models/dashboard_stats.dart';
import '../models/attendance_record.dart';
import '../models/alert.dart';

class DashboardState {
  final DashboardStats stats;
  final List<AttendanceRecord> recentAttendance;
  final List<Alert> recentAlerts;
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.stats = const DashboardStats(),
    this.recentAttendance = const [],
    this.recentAlerts = const [],
    this.isLoading = true,
    this.error,
  });

  DashboardState copyWith({
    DashboardStats? stats,
    List<AttendanceRecord>? recentAttendance,
    List<Alert>? recentAlerts,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return DashboardState(
      stats: stats ?? this.stats,
      recentAttendance: recentAttendance ?? this.recentAttendance,
      recentAlerts: recentAlerts ?? this.recentAlerts,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class DashboardNotifier extends Notifier<DashboardState> {
  @override
  DashboardState build() => const DashboardState();

  DioClient get _dio => ref.read(dioProvider);

  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dio.get(ApiConstants.adminDashboard);
      final data = response.data['data'] ?? response.data;

      final stats = DashboardStats.fromJson(data['stats'] ?? {});
      final recentAttendance = (data['recent_attendance'] as List<dynamic>? ?? [])
          .map((e) => AttendanceRecord.fromJson(e))
          .toList();
      final recentAlerts = (data['recent_alerts'] as List<dynamic>? ?? [])
          .map((e) => Alert.fromJson(e))
          .toList();

      state = DashboardState(
        stats: stats,
        recentAttendance: recentAttendance,
        recentAlerts: recentAlerts,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load dashboard. Pull down to retry.',
      );
    }
  }
}

final dashboardProvider =
    NotifierProvider<DashboardNotifier, DashboardState>(DashboardNotifier.new);
