import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../core/network/api_constants.dart';
import '../models/attendance_record.dart';

class AttendanceState {
  final List<AttendanceRecord> records;
  final AttendanceStats stats;
  final bool isLoading;
  final String? error;
  final String? filterMonth;

  const AttendanceState({
    this.records = const [],
    this.stats = const AttendanceStats(),
    this.isLoading = true,
    this.error,
    this.filterMonth,
  });

  AttendanceState copyWith({
    List<AttendanceRecord>? records,
    AttendanceStats? stats,
    bool? isLoading,
    String? error,
    String? filterMonth,
    bool clearError = false,
    bool clearFilter = false,
  }) {
    return AttendanceState(
      records: records ?? this.records,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      filterMonth: clearFilter ? null : (filterMonth ?? this.filterMonth),
    );
  }
}

class _AttendanceNotifierBase extends Notifier<AttendanceState> {
  final String endpoint;
  _AttendanceNotifierBase(this.endpoint);

  @override
  AttendanceState build() => const AttendanceState();

  DioClient get _dio => ref.read(dioProvider);

  Future<void> fetch({String? month}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final queryParams = month != null && month.isNotEmpty ? {'month': month} : null;
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams != null ? Map<String, dynamic>.from(queryParams) : null,
      );

      final data = response.data;
      List<dynamic> recordsList;
      Map<String, dynamic>? statsJson;

      if (data['data'] is List) {
        recordsList = data['data'];
        statsJson = data['stats'] as Map<String, dynamic>?;
      } else if (data['data'] is Map) {
        final inner = data['data'] as Map<String, dynamic>;
        recordsList = inner['records'] as List<dynamic>? ?? [];
        statsJson = inner['stats'] as Map<String, dynamic>?;
      } else {
        recordsList = [];
        statsJson = data['stats'] as Map<String, dynamic>?;
      }

      final records = recordsList.map((e) => AttendanceRecord.fromJson(e)).toList();
      final stats = statsJson != null ? AttendanceStats.fromJson(statsJson) : const AttendanceStats();

      state = AttendanceState(
        records: records,
        stats: stats,
        isLoading: false,
        filterMonth: month,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load attendance records.');
    }
  }

  void setFilter(String? month) {
    if (month == null || month.isEmpty) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(filterMonth: month);
    }
    fetch(month: month);
  }

  void clearFilter() {
    state = state.copyWith(clearFilter: true);
    fetch();
  }

  String generateCsv({bool includeEmployeeName = false}) {
    final headers = <String>[
      if (includeEmployeeName) 'Employee Name',
      'Date', 'Check In', 'Check Out', 'Total Hours', 'Status',
    ];

    final rows = state.records.map((r) => <String>[
      if (includeEmployeeName) '"${r.employeeName ?? '—'}"',
      '"${r.date}"', '"${r.checkInFormatted}"', '"${r.checkOutFormatted}"',
      '"${r.hoursFormatted}"', '"${r.status}"',
    ]);

    return [headers.join(','), ...rows.map((r) => r.join(','))].join('\n');
  }
}

class AdminAttendanceNotifier extends _AttendanceNotifierBase {
  AdminAttendanceNotifier() : super(ApiConstants.attendance);
}

class EmployeeAttendanceNotifier extends _AttendanceNotifierBase {
  EmployeeAttendanceNotifier() : super(ApiConstants.employeeAttendance);
}

final adminAttendanceProvider =
    NotifierProvider<AdminAttendanceNotifier, AttendanceState>(AdminAttendanceNotifier.new);

final employeeAttendanceProvider =
    NotifierProvider<EmployeeAttendanceNotifier, AttendanceState>(EmployeeAttendanceNotifier.new);
