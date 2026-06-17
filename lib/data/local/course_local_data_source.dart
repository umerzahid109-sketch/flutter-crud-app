// lib/data/local/course_local_data_source.dart

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/course_model.dart';

/// Local persistence layer ("Local Database" in the architecture diagram).
///
/// Responsible ONLY for reading/writing course data to on-device storage.
/// It knows nothing about HTTP or UI. SharedPreferences is used as the storage
/// engine (allowed by the assignment for simple cases); because every public
/// method is expressed in terms of [Course] objects, the underlying engine
/// could later be swapped for Hive or Sqflite without touching the repository.
class CourseLocalDataSource {
  static const String _coursesKey = 'cached_courses_v1';
  static const String _lastSyncKey = 'cached_courses_last_sync_v1';

  /// Persist the full list of courses, replacing whatever was stored before.
  Future<void> cacheCourses(List<Course> courses) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded =
        jsonEncode(courses.map((course) => course.toMap()).toList());
    await prefs.setString(_coursesKey, encoded);
    await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
    debugPrint('[LocalDB] Cached ${courses.length} courses');
  }

  /// Read the cached courses. Returns an empty list when nothing is stored.
  Future<List<Course>> getCachedCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_coursesKey);
    if (raw == null || raw.isEmpty) return <Course>[];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => Course.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[LocalDB] Failed to decode cache: $e');
      return <Course>[];
    }
  }

  /// Insert a course if new, or replace the existing one with the same id.
  Future<void> upsertCourse(Course course) async {
    final courses = await getCachedCourses();
    final index = courses.indexWhere((c) => c.id == course.id);
    if (index == -1) {
      courses.insert(0, course);
    } else {
      courses[index] = course;
    }
    await cacheCourses(courses);
  }

  /// Remove a course from the cache by id.
  Future<void> removeCourse(int id) async {
    final courses = await getCachedCourses();
    courses.removeWhere((c) => c.id == id);
    await cacheCourses(courses);
  }

  /// Timestamp of the last successful sync, if any.
  Future<DateTime?> lastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastSyncKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  /// True when there is at least one cached course.
  Future<bool> hasCache() async {
    final courses = await getCachedCourses();
    return courses.isNotEmpty;
  }

  /// Wipe the cache (used on logout, for example).
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_coursesKey);
    await prefs.remove(_lastSyncKey);
  }
}
