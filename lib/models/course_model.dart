// lib/models/course_model.dart

class Course {
  final int id;
  final String title;
  final String body;
  final int userId;

  Course({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
  });

  /// Factory method to create Course from JSON (from API)
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      userId: json['userId'] ?? 1,
    );
  }

  /// Convert Course to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'userId': userId,
    };
  }

  /// Create a copy with modified fields
  Course copyWith({
    int? id,
    String? title,
    String? body,
    int? userId,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() => 'Course(id: $id, title: $title, body: $body)';
}
