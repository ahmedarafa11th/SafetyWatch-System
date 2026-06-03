import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage_service.dart';
import 'api_constants.dart';
import '../error/exceptions.dart';

final dioProvider = Provider<DioClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return DioClient(secureStorage);
});

class DioClient {
  late final Dio _dio;
  final SecureStorageService _secureStorage;

  DioClient(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add token if available
          final token = await _secureStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          // ==========================================
          // DEBUG: Test Account Bypass Interceptor
          // ==========================================
          if (token == 'mock_test_token_999') {
            await Future.delayed(const Duration(milliseconds: 400)); // Simulate latency
            
            dynamic fakeData = {};
            
            if (options.path.contains('dashboard')) {
              fakeData = {
                'stats': {
                  'total_employees': 42,
                  'active_employees': 38,
                  'cameras_online': 12,
                  'cameras_offline': 1,
                  'unresolved_alerts': 3,
                },
                'recent_attendance': [
                  {
                    'id': 1,
                    'employee': {'id': 1, 'name': 'John Doe'},
                    'camera': {'id': 1, 'name': 'Main Entrance'},
                    'timestamp': DateTime.now().toIso8601String(),
                    'type': 'check_in',
                  }
                ],
                'recent_alerts': [
                  {
                    'id': 1,
                    'camera': {'id': 1, 'name': 'Warehouse Cam 1'},
                    'type': 'person_down',
                    'timestamp': DateTime.now().toIso8601String(),
                    'is_resolved': false,
                    'confidence': 0.95
                  }
                ]
              };
            } else if (options.path.contains('employee/attendance')) {
              fakeData = {
                'stats': {
                  'days_present': 18,
                  'days_absent': 1,
                  'days_late': 2,
                },
                'records': [
                  {
                    'id': 1,
                    'employee': {'id': 999, 'name': 'Test Employee'},
                    'camera': {'id': 1, 'name': 'Main Entrance'},
                    'timestamp': DateTime.now().toIso8601String(),
                    'type': 'check_in',
                  }
                ]
              };
            } else if (options.path.contains('employees')) {
              fakeData = [
                {
                  'id': 999,
                  'name': 'Test Employee',
                  'email': 'employee@test.com',
                  'department': 'Engineering',
                  'position': 'Developer',
                  'status': 'active',
                }
              ];
            } else if (options.path.contains('cameras')) {
              fakeData = [
                {
                  'id': 1,
                  'name': 'Main Entrance',
                  'location': 'Lobby',
                  'ip_address': '192.168.1.10',
                  'is_online': true,
                  'status': 'online'
                }
              ];
            } else if (options.path.contains('attendance')) {
              fakeData = {
                'data': [
                  {
                    'id': 1,
                    'employee': {'id': 999, 'name': 'Test Employee'},
                    'camera': {'id': 1, 'name': 'Main Entrance'},
                    'timestamp': DateTime.now().toIso8601String(),
                    'type': 'check_in',
                  }
                ]
              };
            } else if (options.path.contains('violations')) {
              fakeData = {
                'data': [
                  {
                    'id': 1,
                    'employee': {'id': 999, 'name': 'Test Employee'},
                    'camera': {'id': 1, 'name': 'Warehouse Cam'},
                    'type': 'no_helmet',
                    'timestamp': DateTime.now().toIso8601String(),
                    'is_resolved': false,
                  }
                ]
              };
            }
            
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'data': fakeData},
              )
            );
          }
          // ==========================================

          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          // You could handle 401 Unauthorized here (e.g., refresh token or logout)
          return handler.next(e);
        },
      ),
    );

    // Optional: Add logging interceptor for debugging
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }

  Dio get dio => _dio;

  // Helper method to process responses and map errors
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> delete(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.delete(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data['message'] ?? 'An error occurred';
        return ServerException(statusCode: statusCode, message: message);
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
      default:
        return ServerException(message: e.message);
    }
  }
}
