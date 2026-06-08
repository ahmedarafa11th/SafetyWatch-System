import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../core/network/api_constants.dart';
import '../models/employee.dart';
import 'package:dio/dio.dart';

class EmployeesState {
  final List<Employee> employees;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String searchQuery;

  const EmployeesState({
    this.employees = const [],
    this.isLoading = true,
    this.isSaving = false,
    this.error,
    this.searchQuery = '',
  });

  EmployeesState copyWith({
    List<Employee>? employees,
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? searchQuery,
    bool clearError = false,
  }) {
    return EmployeesState(
      employees: employees ?? this.employees,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class EmployeesNotifier extends Notifier<EmployeesState> {
  @override
  EmployeesState build() => const EmployeesState();

  DioClient get _dio => ref.read(dioProvider);

  Future<void> fetch({String search = ''}) async {
    state = state.copyWith(isLoading: true, clearError: true, searchQuery: search);
    try {
      final queryParams = search.isNotEmpty ? {'search': search} : null;
      final response = await _dio.get(
        ApiConstants.employees,
        queryParameters: queryParams != null ? Map<String, dynamic>.from(queryParams) : null,
      );

      final data = response.data;
      final List<dynamic> list = data is List ? data : (data['data'] ?? []);
      final employees = list.map((e) => Employee.fromJson(e)).toList();
      state = state.copyWith(employees: employees, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load employees.');
    }
  }

  Future<bool> addEmployee(EmployeeFormData form) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      dynamic data = form.toJson();
      if (form.photoFront != null || form.photoLeft != null || form.photoRight != null) {
        data = FormData.fromMap(form.toJson());
        if (form.photoFront != null) {
          data.files.add(MapEntry('photo_front', await MultipartFile.fromFile(form.photoFront!.path, filename: form.photoFront!.name)));
        }
        if (form.photoLeft != null) {
          data.files.add(MapEntry('photo_left', await MultipartFile.fromFile(form.photoLeft!.path, filename: form.photoLeft!.name)));
        }
        if (form.photoRight != null) {
          data.files.add(MapEntry('photo_right', await MultipartFile.fromFile(form.photoRight!.path, filename: form.photoRight!.name)));
        }
      }

      await _dio.post(ApiConstants.employees, data: data);
      state = state.copyWith(isSaving: false);
      await fetch(search: state.searchQuery);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: _extractError(e, 'Failed to add employee.'));
      return false;
    }
  }

  Future<bool> updateEmployee(int id, EmployeeFormData form) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      dynamic data = form.toJson();
      if (form.photoFront != null || form.photoLeft != null || form.photoRight != null) {
        final mapData = form.toJson();
        mapData['_method'] = 'PUT';
        data = FormData.fromMap(mapData);
        if (form.photoFront != null) {
          data.files.add(MapEntry('photo_front', await MultipartFile.fromFile(form.photoFront!.path, filename: form.photoFront!.name)));
        }
        if (form.photoLeft != null) {
          data.files.add(MapEntry('photo_left', await MultipartFile.fromFile(form.photoLeft!.path, filename: form.photoLeft!.name)));
        }
        if (form.photoRight != null) {
          data.files.add(MapEntry('photo_right', await MultipartFile.fromFile(form.photoRight!.path, filename: form.photoRight!.name)));
        }
        // If sending FormData for an update in Laravel, we typically use POST with _method=PUT
        await _dio.post(ApiConstants.employeeDetails(id.toString()), data: data);
      } else {
        await _dio.put(ApiConstants.employeeDetails(id.toString()), data: data);
      }
      
      state = state.copyWith(isSaving: false);
      await fetch(search: state.searchQuery);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: _extractError(e, 'Failed to update employee.'));
      return false;
    }
  }

  Future<bool> deleteEmployee(int id) async {
    try {
      await _dio.delete(ApiConstants.employeeDetails(id.toString()));
      await fetch(search: state.searchQuery);
      return true;
    } catch (e) {
      state = state.copyWith(error: _extractError(e, 'Failed to delete employee.'));
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

final employeesProvider =
    NotifierProvider<EmployeesNotifier, EmployeesState>(EmployeesNotifier.new);
