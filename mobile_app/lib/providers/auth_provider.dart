import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../core/network/api_constants.dart';
import '../core/storage/secure_storage_service.dart';
import '../models/user.dart';

// Auth state
class AuthState {
  final User? user;
  final bool isLoading;
  final bool isInitialized;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isInitialized = false,
    this.error,
  });

  bool get isAuthenticated => user != null;
  bool get isAdmin => user?.isAdmin ?? false;
  bool get isEmployee => user?.isEmployee ?? false;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    bool? isInitialized,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Auth result for login/register operations
class AuthResult {
  final bool success;
  final String? message;
  final String? role;
  final String? name;

  const AuthResult({
    required this.success,
    this.message,
    this.role,
    this.name,
  });
}

// Auth Notifier (Riverpod 3 Notifier pattern)
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  DioClient get _dio => ref.read(dioProvider);
  SecureStorageService get _storage => ref.read(secureStorageProvider);

  /// Initialize auth state from stored token/user on app launch.
  Future<void> initialize() async {
    try {
      final token = await _storage.getToken();
      final userJson = await _storage.getUserData();

      if (token != null && userJson != null) {
        try {
          final userData = jsonDecode(userJson);
          final user = User.fromJson(userData);
          state = AuthState(user: user, isInitialized: true);
        } catch (_) {
          await _storage.clearAll();
          state = const AuthState(isInitialized: true);
        }
      } else {
        state = const AuthState(isInitialized: true);
      }
    } catch (_) {
      state = const AuthState(isInitialized: true);
    }
  }

  /// POST /api/auth/login
  Future<AuthResult> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    // ==========================================
    // DEBUG: Test Account Bypass
    // ==========================================
    if (email.toLowerCase() == 'admin@test.com' || email.toLowerCase() == 'employee@test.com') {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network latency
      
      final isTestAdmin = email.toLowerCase() == 'admin@test.com';
      final testUser = User(
        id: 999,
        name: isTestAdmin ? 'Test Admin' : 'Test Employee',
        email: email,
        role: isTestAdmin ? 'admin' : 'employee',
      );

      final token = 'mock_test_token_999';

      await _storage.saveToken(token);
      await _storage.saveUserRole(testUser.role);
      await _storage.saveUserData(jsonEncode(testUser.toJson()));

      state = AuthState(user: testUser, isInitialized: true);
      return AuthResult(success: true, role: testUser.role);
    }
    // ==========================================

    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      final json = response.data;
      final userData = json['data']['user'];
      final token = json['data']['token'] as String;

      final user = User.fromJson(userData);

      await _storage.saveToken(token);
      await _storage.saveUserRole(user.role);
      await _storage.saveUserData(jsonEncode(user.toJson()));

      state = AuthState(user: user, isInitialized: true);

      return AuthResult(success: true, role: user.role);
    } catch (e) {
      final message = _extractErrorMessage(e, 'Invalid email or password.');
      state = state.copyWith(isLoading: false, error: message);
      return AuthResult(success: false, message: message);
    }
  }

  /// POST /api/auth/register
  Future<AuthResult> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email.trim().toLowerCase(),
          'password': password,
          'password_confirmation': password,
          'role': role,
        },
      );

      final json = response.data;
      final userName = json['data']?['user']?['name'] as String? ?? name;

      state = state.copyWith(isLoading: false);

      return AuthResult(success: true, name: userName);
    } catch (e) {
      final message = _extractErrorMessage(e, 'Registration failed.');
      state = state.copyWith(isLoading: false, error: message);
      return AuthResult(success: false, message: message);
    }
  }

  /// POST /api/auth/logout
  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } catch (_) {}
    await _storage.clearAll();
    state = const AuthState(isInitialized: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  String _extractErrorMessage(dynamic error, String fallback) {
    if (error is Exception) {
      final errStr = error.toString();
      if (errStr.contains('message:')) {
        final match = RegExp(r'message:\s*(.+)').firstMatch(errStr);
        if (match != null) return match.group(1)!.trim();
      }
    }
    return fallback;
  }
}

// Provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
