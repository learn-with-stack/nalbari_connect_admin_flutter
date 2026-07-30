import 'package:equatable/equatable.dart';

enum AppointmentStatus {
  PENDING('PENDING'),
  APPROVED('APPROVED'),
  REJECTED('REJECTED'),
  RESCHEDULED('RESCHEDULED'),
  COMPLETED('COMPLETED'),
  CANCELLED('CANCELLED');

  final String value;
  const AppointmentStatus(this.value);

  factory AppointmentStatus.fromString(String value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => AppointmentStatus.PENDING,
    );
  }
}

class AppointmentModel extends Equatable {
  final int id;
  final String name;
  final String mobile;
  final int officeId;
  final DateTime date;
  final AppointmentTime time;
  final String purpose;
  final AppointmentStatus status;
  final String? rescheduledReason;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppointmentModel({
    required this.id,
    required this.name,
    required this.mobile,
    required this.officeId,
    required this.date,
    required this.time,
    this.purpose = '',
    required this.status,
    this.rescheduledReason,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? json['applicantName'] as String? ?? '',
      mobile: json['mobile'] as String? ?? json['mobileNumber'] as String? ?? '',
      officeId: (json['officeId'] as num?)?.toInt() ?? 0,
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      time: AppointmentTime.fromJson(json['time']),
      purpose: json['purpose'] as String? ?? '',
      status: AppointmentStatus.fromString(json['status'] ?? 'PENDING'),
      rescheduledReason: json['rescheduledReason'] as String?,
      rejectionReason: json['rejectionReason'] as String? ?? json['rejectReason'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'officeId': officeId,
      'date': date.toIso8601String(),
      'time': time.toJson(),
      'purpose': purpose,
      'status': status.value,
      'rescheduledReason': rescheduledReason,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id, name, mobile, officeId, date, time, purpose, status,
    rescheduledReason, rejectionReason, createdAt, updatedAt
  ];
}

class AppointmentTime extends Equatable {
  final int hour;
  final int minute;
  final int second;
  final int nano;

  const AppointmentTime({
    required this.hour,
    required this.minute,
    this.second = 0,
    this.nano = 0,
  });

  factory AppointmentTime.fromJson(dynamic json) {
    if (json is String) {
      final parts = json.split(':');
      return AppointmentTime(
        hour: int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0,
        minute: int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0,
        second: int.tryParse(parts.length > 2 ? parts[2] : '') ?? 0,
      );
    }
    if (json is! Map<String, dynamic>) return const AppointmentTime(hour: 0, minute: 0);
    return AppointmentTime(
      hour: json['hour'] as int? ?? 0,
      minute: json['minute'] as int? ?? 0,
      second: json['second'] as int? ?? 0,
      nano: json['nano'] as int? ?? 0,
    );
  }

  String toJson() {
    return formattedTime;
  }

  String get formattedTime => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  @override
  List<Object?> get props => [hour, minute, second, nano];
}

class AcceptAppointmentRequest extends Equatable {
  // No additional fields needed, ID comes from URL

  const AcceptAppointmentRequest();

  Map<String, dynamic> toJson() {
    return {};
  }

  @override
  List<Object?> get props => [];
}

class RejectAppointmentRequest extends Equatable {
  final String reason;

  const RejectAppointmentRequest({required this.reason});

  Map<String, dynamic> toJson() {
    return {'reason': reason};
  }

  @override
  List<Object?> get props => [reason];
}

class RescheduleAppointmentRequest extends Equatable {
  final DateTime date;
  final AppointmentTime time;

  const RescheduleAppointmentRequest({
    required this.date,
    required this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'time': time.toJson(),
    };
  }

  @override
  List<Object?> get props => [date, time];
}
