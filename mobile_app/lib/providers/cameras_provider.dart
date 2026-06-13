import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../core/network/dio_client.dart';
import '../core/network/api_constants.dart';
import '../models/camera.dart';

class CamerasState {
  final List<Camera> cameras;
  final CameraStats stats;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const CamerasState({
    this.cameras = const [],
    this.stats = const CameraStats(),
    this.isLoading = true,
    this.isSaving = false,
    this.error,
  });

  CamerasState copyWith({
    List<Camera>? cameras,
    CameraStats? stats,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) {
    return CamerasState(
      cameras: cameras ?? this.cameras,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CamerasNotifier extends Notifier<CamerasState> {
  @override
  CamerasState build() => const CamerasState();

  DioClient get _dio => ref.read(dioProvider);

  Future<void> fetch({bool background = false}) async {
    if (!background) {
      state = state.copyWith(isLoading: true, clearError: true);
    }
    try {
      final response = await _dio.get(ApiConstants.cameras);
      final data = response.data['data'] ?? response.data;
      final List<dynamic> list = data['cameras'] ?? [];
      final cameras = list.map((e) => Camera.fromJson(e)).toList();
      final stats = CameraStats.fromJson(data['stats'] ?? {});

      state = state.copyWith(cameras: cameras, stats: stats, isLoading: false);
    } catch (e) {
      if (!background) {
        state = state.copyWith(isLoading: false, error: 'Failed to load cameras.');
      }
    }
  }

  Future<bool> addCamera(CameraFormData form) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _dio.post(ApiConstants.cameras, data: form.toJson());
      state = state.copyWith(isSaving: false);
      await fetch();
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: _extractError(e, 'Failed to add camera.'));
      return false;
    }
  }

  Future<bool> updateCamera(int id, CameraFormData form) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _dio.put(ApiConstants.cameraDetails(id.toString()), data: form.toJson());
      state = state.copyWith(isSaving: false);
      await fetch();
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: _extractError(e, 'Failed to update camera.'));
      return false;
    }
  }

  Future<bool> uploadTestVideo(PlatformFile videoFile) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      if (videoFile.path == null) return false;
      final formData = FormData.fromMap({
        'video': await MultipartFile.fromFile(videoFile.path!, filename: videoFile.name),
      });
      final uploadResponse = await _dio.post('/api/admin/cameras/upload-video', data: formData);
      if (uploadResponse.statusCode == 200) {
        final url = uploadResponse.data['data']['url'];
        await _dio.post(ApiConstants.cameras, data: {
          'name': 'Test Video Camera',
          'location': 'Virtual Upload',
          'ip_address': null,
          'stream_url': url,
          'status': 'online',
          'is_ai_enabled': true,
        });
        await fetch();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: _extractError(e, 'Failed to upload test video.'));
      return false;
    }
  }

  Future<bool> deleteCamera(int id) async {
    try {
      await _dio.delete(ApiConstants.cameraDetails(id.toString()));
      await fetch();
      return true;
    } catch (e) {
      state = state.copyWith(error: _extractError(e, 'Failed to delete camera.'));
      return false;
    }
  }

  Future<bool> toggleStatus(int id) async {
    state = state.copyWith(isSaving: true);
    try {
      await _dio.post(ApiConstants.toggleCameraStatus(id.toString()));
      state = state.copyWith(isSaving: false);
      await fetch();
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: _extractError(e, 'Failed to toggle camera status.'));
      return false;
    }
  }

  String _extractError(dynamic error, String fallback) {
    try {
      if (error.toString().contains('message:')) {
        final match = RegExp(r'message:\s*(.+)').firstMatch(error.toString());
        if (match != null) return match.group(1)!.trim();
      }
    } catch (_) {}
    return fallback;
  }
}

final camerasProvider =
    NotifierProvider<CamerasNotifier, CamerasState>(CamerasNotifier.new);
