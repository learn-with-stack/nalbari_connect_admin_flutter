enum AppointmentStatus { pending, approved, rejected }

enum ComplaintStatus { newRequest, inReview, resolved }

enum ComplaintPriority { low, medium, high }

enum AreaType { ward, panchayat }

class NewsItem {
  const NewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.publishedAt,
  });

  final String id;
  final String title;
  final String summary;
  final String body;
  final DateTime publishedAt;

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      body: json['body'] as String,
      publishedAt: DateTime.parse(json['published_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'body': body,
      'published_at': publishedAt.toIso8601String(),
    };
  }
}

class AppointmentRequest {
  const AppointmentRequest({
    required this.id,
    required this.fullName,
    required this.withPerson,
    required this.date,
    required this.time,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String fullName;
  final String withPerson;
  final DateTime date;
  final String time;
  final String reason;
  final AppointmentStatus status;
  final DateTime createdAt;

  factory AppointmentRequest.fromJson(Map<String, dynamic> json) {
    return AppointmentRequest(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      withPerson: json['with_person'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      reason: json['reason'] as String,
      status: _appointmentStatusFromJson(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'with_person': withPerson,
      'date': date.toIso8601String().split('T').first,
      'time': time,
      'reason': reason,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AppointmentRequest copyWith({AppointmentStatus? status}) {
    return AppointmentRequest(
      id: id,
      fullName: fullName,
      withPerson: withPerson,
      date: date,
      time: time,
      reason: reason,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}

class ComplaintRequest {
  const ComplaintRequest({
    required this.id,
    required this.reporterName,
    required this.areaType,
    required this.areaNumber,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.mediaName,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String reporterName;
  final AreaType areaType;
  final String areaNumber;
  final String description;
  final ComplaintStatus status;
  final ComplaintPriority priority;
  final DateTime createdAt;
  final String? mediaName;
  final double? latitude;
  final double? longitude;

  factory ComplaintRequest.fromJson(Map<String, dynamic> json) {
    return ComplaintRequest(
      id: json['id'] as String,
      reporterName: json['reporter_name'] as String,
      areaType: _areaTypeFromJson(json['area_type'] as String),
      areaNumber: json['area_number'] as String,
      description: json['description'] as String,
      status: _complaintStatusFromJson(json['status'] as String),
      priority: _complaintPriorityFromJson(json['priority'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      mediaName: json['media_name'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporter_name': reporterName,
      'area_type': areaType.name,
      'area_number': areaNumber,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'created_at': createdAt.toIso8601String(),
      'media_name': mediaName,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  ComplaintRequest copyWith({
    ComplaintStatus? status,
    ComplaintPriority? priority,
  }) {
    return ComplaintRequest(
      id: id,
      reporterName: reporterName,
      areaType: areaType,
      areaNumber: areaNumber,
      description: description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      mediaName: mediaName,
      latitude: latitude,
      longitude: longitude,
    );
  }
}

AppointmentStatus _appointmentStatusFromJson(String value) {
  return AppointmentStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => AppointmentStatus.pending,
  );
}

ComplaintStatus _complaintStatusFromJson(String value) {
  return ComplaintStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => ComplaintStatus.newRequest,
  );
}

ComplaintPriority _complaintPriorityFromJson(String value) {
  return ComplaintPriority.values.firstWhere(
    (priority) => priority.name == value,
    orElse: () => ComplaintPriority.medium,
  );
}

AreaType _areaTypeFromJson(String value) {
  return AreaType.values.firstWhere(
    (areaType) => areaType.name == value,
    orElse: () => AreaType.ward,
  );
}
