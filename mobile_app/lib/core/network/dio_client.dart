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
