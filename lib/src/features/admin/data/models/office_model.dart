import 'package:equatable/equatable.dart';

class OfficeModel extends Equatable {
  final int id;
  final String name;
  final String address;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OfficeModel({
    required this.id,
    required this.name,
    required this.address,
    required this.active,
    this.createdAt,
    this.updatedAt,
  });

  factory OfficeModel.fromJson(Map<String, dynamic> json) {
    return OfficeModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      active: json['active'] as bool? ?? true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'active': active,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  OfficeModel copyWith({
    int? id,
    String? name,
    String? address,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OfficeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, address, active, createdAt, updatedAt];
}

class CreateOfficeRequest extends Equatable {
  final String name;
  final String address;
  final bool active;

  const CreateOfficeRequest({
    required this.name,
    required this.address,
    this.active = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'active': active,
    };
  }

  @override
  List<Object?> get props => [name, address, active];
}
