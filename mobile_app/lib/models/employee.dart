import 'user.dart';

class Employee {
  final int id;
  final User? user;
  final String department;
  final String position;
  final String status; // 'active', 'inactive', 'on_leave'
  final String? joinDate;
  final String? phone;
  final String? shiftStart;
  final String? shiftEnd;

  const Employee({
    required this.id,
    this.user,
    required this.department,
    required this.position,
    required this.status,
    this.joinDate,
    this.phone,
    this.shiftStart,
    this.shiftEnd,
  });

  String get name => user?.name ?? '—';
  String get email => user?.email ?? '—';

  String get statusDisplay {
    switch (status) {
      case 'on_leave':
        return 'On Leave';
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      default:
        return status;
    }
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as int,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      department: json['department'] as String? ?? '',
      position: json['position'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      joinDate: json['join_date'] as String?,
      phone: json['phone'] as String?,
      shiftStart: json['shift_start'] as String?,
      shiftEnd: json['shift_end'] as String?,
    );
  }
}

class EmployeeFormData {
  String email;
  String department;
  String position;
  String status;
  String joinDate;
  String phone;
  String shiftStart;
  String shiftEnd;

  EmployeeFormData({
    this.email = '',
    this.department = '',
    this.position = '',
    this.status = 'active',
    this.joinDate = '',
    this.phone = '',
    this.shiftStart = '08:00',
    this.shiftEnd = '17:00',
  });

  Map<String, dynamic> toJson() => {
    if (email.isNotEmpty) 'email': email,
    'department': department,
    'position': position,
    'status': status,
    'join_date': joinDate,
    'phone': phone,
    'shift_start': shiftStart,
    'shift_end': shiftEnd,
  };

  factory EmployeeFormData.fromEmployee(Employee emp) {
    return EmployeeFormData(
      email: emp.email,
      department: emp.department,
      position: emp.position,
      status: emp.status,
      joinDate: emp.joinDate ?? '',
      phone: emp.phone ?? '',
      shiftStart: emp.shiftStart?.substring(0, 5) ?? '08:00',
      shiftEnd: emp.shiftEnd?.substring(0, 5) ?? '17:00',
    );
  }
}
