class NewsModel {
  final int id;
  final String title;
  final String content;
  final String? image;
  final String status; // draft | publish
  final DateTime createdAt;

  const NewsModel({
    required this.id,
    required this.title,
    required this.content,
    this.image,
    required this.status,
    required this.createdAt,
  });

  bool get isPublished => status == 'publish';

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      image: json['image'],
      status: json['is_published'] ?? json['status'] ?? 'draft',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class ActivityModel {
  final int id;
  final String name;
  final String? description;
  final DateTime? date;
  final String status; // active | inactive

  const ActivityModel({
    required this.id,
    required this.name,
    this.description,
    this.date,
    required this.status,
  });

  bool get isActive => status == 'active';

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      status: json['status'] ?? 'active',
    );
  }
}
