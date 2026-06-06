import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../core/network/api_constants.dart';
import '../models/violation.dart';
import '../models/camera.dart';

class ViolationsState {
  final List<Violation> violations;
  final ViolationStats stats;
  final List<Camera> cameras;
  final bool isLoading;
  final String? error;
  final String? cameraFilter;

  const ViolationsState({
    this.violations = const [],
    this.stats = const ViolationStats(),
    this.cameras = const [],
    this.isLoading = true,
    this.error,
    this.cameraFilter,
  });

  ViolationsState copyWith({
    List<Violation>? violations,
    ViolationStats? stats,
    List<Camera>? cameras,
    bool? isLoading,
    String? error,
    String? cameraFilter,
    bool clearError = false,
    bool clearFilter = false,
  }) {
    return ViolationsState(
      violations: violations ?? this.violations,
      stats: stats ?? this.stats,
      cameras: cameras ?? this.cameras,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      cameraFilter: clearFilter ? null : (cameraFilter ?? this.cameraFilter),
    );
  }
}

class ViolationsNotifier extends Notifier<ViolationsState> {
  @override
  ViolationsState build() => const ViolationsState();

  DioClient get _dio => ref.read(dioProvider);

  Future<void> fetch({String? cameraId}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final queryParams = cameraId != null && cameraId.isNotEmpty ? {'camera_id': cameraId} : null;
      final response = await _dio.get(
        ApiConstants.violations,
        queryParameters: queryParams != null ? Map<String, dynamic>.from(queryParams) : null,
      );

      final data = response.data;
      final List<dynamic> list = data['data'] is List ? data['data'] : (data['data'] ?? []);
      final violations = list.map((e) => Violation.fromJson(e)).toList();
      final stats = data['stats'] != null ? ViolationStats.fromJson(data['stats']) : const ViolationStats();

      state = state.copyWith(
        violations: violations, stats: stats, isLoading: false, cameraFilter: cameraId,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load violations.');
    }
  }

  Future<void> fetchCameras() async {
    try {
      final response = await _dio.get(ApiConstants.cameras);
      final data = response.data['data'] ?? response.data;
      final List<dynamic> list = data['cameras'] ?? [];
      final cameras = list.map((e) => Camera.fromJson(e)).toList();
      state = state.copyWith(cameras: cameras);
    } catch (_) {}
  }

  void setCameraFilter(String? cameraId) {
    if (cameraId == null || cameraId.isEmpty) {
      state = state.copyWith(clearFilter: true);
      fetch();
    } else {
      state = state.copyWith(cameraFilter: cameraId);
      fetch(cameraId: cameraId);
    }
  }

  String generateCsv() {
    final headers = ['Type', 'Camera', 'Employee', 'Detected At', 'Severity', 'Status'];
    final rows = state.violations.map((v) => [
      '"${v.type}"', '"${v.cameraName ?? '—'}"', '"${v.employeeName ?? 'Unknown'}"',
      '"${v.formattedDate}"', '"${v.severity}"', '"${v.status}"',
    ]);
    return [headers.join(','), ...rows.map((r) => r.join(','))].join('\n');
  }
}

final violationsProvider =
    NotifierProvider<ViolationsNotifier, ViolationsState>(ViolationsNotifier.new);
