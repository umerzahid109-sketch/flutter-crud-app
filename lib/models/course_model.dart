// lib/models/course_model.dart

/// Domain model representing a single course.
///
/// Two serialization paths are intentionally kept separate:
///  - [toJson]  -> shape expected by the REST API on create/update (no `id`,
///                 because the server assigns it).
///  - [toMap]/[fromMap] -> full local-cache shape (includes `id`) used by the
///                 local database layer so a course can be restored offline
///                 exactly as it was fetched.
class Course {
  final int id;
  final String title;
  final String body;
  final int userId;

  const Course({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
  });

  /// Create a [Course] from API JSON.
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      userId: json['userId'] as int? ?? 1,
    );
  }

  /// Convert to API JSON (used for POST/PUT bodies — no `id`).
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'userId': userId,
    };
  }

  /// Full map for local persistence (includes `id`).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'userId': userId,
    };
  }

  /// Restore from a locally cached map.
  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] as int? ?? 0,
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      userId: map['userId'] as int? ?? 1,
    );
  }

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
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Course &&
          other.id == id &&
          other.title == title &&
          other.body == body &&
          other.userId == userId);

  @override
  int get hashCode => Object.hash(id, title, body, userId);

  @override
  String toString() => 'Course(id: $id, title: $title, body: $body)';
}
