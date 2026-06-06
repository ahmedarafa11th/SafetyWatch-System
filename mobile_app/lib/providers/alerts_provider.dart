import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../core/network/api_constants.dart';
import '../models/alert.dart';

class AlertsState {
  final List<Alert> alerts;
  final AlertStats stats;
  final bool isLoading;
  final String? error;
  final int? actioningId;

  const AlertsState({
    this.alerts = const [],
    this.stats = const AlertStats(),
    this.isLoading = true,
    this.error,
    this.actioningId,
  });

  AlertsState copyWith({
    List<Alert>? alerts,
    AlertStats? stats,
    bool? isLoading,
    String? error,
    int? actioningId,
    bool clearError = false,
    bool clearAction = false,
  }) {
    return AlertsState(
      alerts: alerts ?? this.alerts,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      actioningId: clearAction ? null : (actioningId ?? this.actioningId),
    );
  }
}

class AlertsNotifier extends Notifier<AlertsState> {
  @override
  AlertsState build() => const AlertsState();

  DioClient get _dio => ref.read(dioProvider);

  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dio.get(ApiConstants.alerts);
      final data = response.data['data'] ?? response.data;

      List<dynamic> alertsList;
      if (data['alerts'] is Map && data['alerts']['data'] != null) {
        alertsList = data['alerts']['data'];
      } else if (data['alerts'] is List) {
        alertsList = data['alerts'];
      } else {
        alertsList = [];
      }

      final alerts = alertsList.map((e) => Alert.fromJson(e)).toList();
      final stats = AlertStats.fromJson(data['stats'] ?? {});

      state = AlertsState(alerts: alerts, stats: stats, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load alerts.');
    }
  }

  Future<bool> resolve(int id) async {
    state = state.copyWith(actioningId: id);
    try {
      await _dio.post(ApiConstants.resolveAlert(id.toString()), data: {});
      state = state.copyWith(clearAction: true);
      await fetch();
      return true;
    } catch (e) {
      state = state.copyWith(clearAction: true, error: 'Failed to resolve alert.');
      return false;
    }
  }

  Future<bool> dismiss(int id) async {
    state = state.copyWith(actioningId: id);
    try {
      await _dio.post(ApiConstants.dismissAlert(id.toString()), data: {});
      state = state.copyWith(clearAction: true);
      await fetch();
      return true;
    } catch (e) {
      state = state.copyWith(clearAction: true, error: 'Failed to dismiss alert.');
      return false;
    }
  }

  Future<bool> markAllRead() async {
    try {
      await _dio.post(ApiConstants.markAllAlertsRead, data: {});
      await fetch();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to mark all as read.');
      return false;
    }
  }
}

final alertsProvider =
    NotifierProvider<AlertsNotifier, AlertsState>(AlertsNotifier.new);
