import 'package:equatable/equatable.dart';

enum NewsType {
  news('NEWS'),
  campaign('CAMPAIGN'),
  scheme('SCHEME');

  final String value;
  const NewsType(this.value);

  factory NewsType.fromString(String value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => NewsType.news,
    );
  }
}

class NewsModel extends Equatable {
  final int id;
  final String title;
  final String description;
  final NewsType type;
  final List<String>? mediaUrls;
  final String? author;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NewsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.mediaUrls,
    this.author,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    final mediaUrlsData = json['mediaUrls'] ?? json['media'];
    List<String>? parsedUrls;

    if (mediaUrlsData != null) {
      if (mediaUrlsData is List) {
        parsedUrls = mediaUrlsData
            .map((item) {
              if (item is String) return item;
              if (item is Map) return item['url']?.toString() ?? item['path']?.toString() ?? '';
              return '';
            })
            .where((url) => url.isNotEmpty)
            .toList();
      }
    }

    return NewsModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: NewsType.fromString(json['type'] ?? 'NEWS'),
      mediaUrls: parsedUrls,
      author: json['author'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.value,
      if (mediaUrls != null) 'mediaUrls': mediaUrls,
      'author': author,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  NewsModel copyWith({
    int? id,
    String? title,
    String? description,
    NewsType? type,
    List<String>? mediaUrls,
    String? author,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NewsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    type,
    mediaUrls,
    author,
    createdAt,
    updatedAt,
  ];
}

class CreateNewsRequest extends Equatable {
  final String title;
  final String description;
  final NewsType type;
  final List<String>? mediaUrls;

  const CreateNewsRequest({
    required this.title,
    required this.description,
    required this.type,
    this.mediaUrls,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'published': true,
      'contents': [
        {
          'language': 'EN',
          'title': title,
          'description': description,
        },
      ],
    };
  }

  @override
  List<Object?> get props => [title, description, type, mediaUrls];
}
