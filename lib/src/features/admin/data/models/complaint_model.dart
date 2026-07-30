import 'package:equatable/equatable.dart';

enum ComplaintStatus {
  OPEN('OPEN'),
  IN_PROGRESS('IN_PROGRESS'),
  RESOLVED('RESOLVED'),
  REJECTED('REJECTED');

  final String value;
  const ComplaintStatus(this.value);

  factory ComplaintStatus.fromString(String value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => ComplaintStatus.OPEN,
    );
  }
}

enum AreaType {
  WARD('WARD'),
  PANCHAYAT('PANCHAYAT');

  final String value;
  const AreaType(this.value);

  factory AreaType.fromString(String value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => AreaType.WARD,
    );
  }
}

class ComplaintModel extends Equatable {
  final int id;
  final String title;
  final String description;
  final String userMobile;
  final String? userName;
  final String? userAadhaar;
  final List<String>? mediaUrls;
  final String? voiceNoteUrl;
  final ComplaintStatus status;
  final AreaType? areaType;
  final String? area;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ComplaintModel({
    required this.id,
    required this.title,
    required this.description,
    required this.userMobile,
    this.userName,
    this.userAadhaar,
    this.mediaUrls,
    this.voiceNoteUrl,
    required this.status,
    this.areaType,
    this.area,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    final mediaUrlsData = json['mediaUrls'] ?? json['media'];
    final mediaUrls = mediaUrlsData is List
        ? mediaUrlsData
            .map((item) {
              if (item is String) return item;
              if (item is Map) return item['url']?.toString() ?? item['path']?.toString() ?? '';
              return '';
            })
            .where((url) => url.isNotEmpty)
            .toList()
        : <String>[];
    final voiceNoteData = json['voiceNoteUrl'] ?? json['voiceNote'];
    return ComplaintModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      userMobile: json['userMobile'] as String? ?? json['mobileNumber'] as String? ?? '',
      userName: json['userName'] as String?,
      userAadhaar: json['userAadhaar'] as String?,
      mediaUrls: mediaUrls,
      voiceNoteUrl: voiceNoteData is Map ? voiceNoteData['url']?.toString() : voiceNoteData?.toString(),
      status: ComplaintStatus.fromString(json['status'] ?? 'OPEN'),
      areaType: json['areaType'] != null ? AreaType.fromString(json['areaType']) : null,
      area: json['area'] as String? ?? json['areaNumber'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'userMobile': userMobile,
      'userName': userName,
      'userAadhaar': userAadhaar,
      'mediaUrls': mediaUrls,
      'voiceNoteUrl': voiceNoteUrl,
      'status': status.value,
      'areaType': areaType?.value,
      'area': area,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id, title, description, userMobile, userName, userAadhaar,
    mediaUrls, voiceNoteUrl, status, areaType, area, createdAt, updatedAt
  ];
}

class UpdateComplaintStatusRequest extends Equatable {
  final ComplaintStatus status;

  const UpdateComplaintStatusRequest({required this.status});

  Map<String, dynamic> toJson() {
    return {'status': status.value};
  }

  @override
  List<Object?> get props => [status];
}
