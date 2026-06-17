// lib/data/repositories/course_repository.dart

import 'package:flutter/foundation.dart';

import '../../models/course_model.dart';
import '../../services/api_service.dart';
import '../local/course_local_data_source.dart';

/// Outcome of a courses fetch, carrying the data plus where it came from.
class CoursesResult {
  final List<Course> courses;

  /// True when the data was served from the local cache because the network
  /// request failed (i.e. the device is effectively offline).
  final bool fromCache;

  /// When the cache that produced [courses] was last synced with the server.
  final DateTime? lastSync;

  const CoursesResult({
    required this.courses,
    required this.fromCache,
    this.lastSync,
  });
}

/// Single source of truth for course data.
///
/// Sits between the state-management layer and the two data sources:
///
///   State (CourseProvider) -> CourseRepository -> ApiService     (network)
///                                              \-> LocalDataSource (cache)
///
/// The repository owns the offline policy: it always tries the network first,
/// mirrors every successful response into the local cache, and transparently
/// falls back to the cache when the network is unavailable.
class CourseRepository {
  final ApiService _apiService;
  final CourseLocalDataSource _localDataSource;

  CourseRepository({
    ApiService? apiService,
    CourseLocalDataSource? localDataSource,
  })  : _apiService = apiService ?? ApiService(),
        _localDataSource = localDataSource ?? CourseLocalDataSource();

  /// Fetch courses, preferring fresh network data and caching it.
  ///
  /// If the network call fails:
  ///  - returns cached data when available (offline mode), or
  ///  - rethrows the error when there is nothing cached to show.
  Future<CoursesResult> getCourses({bool forceRefresh = false}) async {
    try {
      final remote = await _apiService.fetchCourses();
      // Synchronize the local store with the latest server data.
      await _localDataSource.cacheCourses(remote);
      return CoursesResult(courses: remote, fromCache: false);
    } catch (e) {
      debugPrint('[Repository] Network fetch failed ($e) — trying cache');
      final cached = await _localDataSource.getCachedCourses();
      if (cached.isNotEmpty) {
        final lastSync = await _localDataSource.lastSyncTime();
        return CoursesResult(
          courses: cached,
          fromCache: true,
          lastSync: lastSync,
        );
      }
      rethrow; // No cache to fall back on — surface the error to the UI.
    }
  }

  /// Read straight from the cache without hitting the network.
  Future<List<Course>> getCachedCourses() =>
      _localDataSource.getCachedCourses();

  /// Create a course on the server, then mirror it into the cache.
  Future<Course> createCourse({
    required String title,
    required String body,
    int userId = 1,
  }) async {
    final draft = Course(id: 0, title: title, body: body, userId: userId);
    final created = await _apiService.createCourse(draft);
    await _localDataSource.upsertCourse(created);
    return created;
  }

  /// Update a course on the server, then mirror it into the cache.
  Future<Course> updateCourse({
    required int id,
    required String title,
    required String body,
    int userId = 1,
  }) async {
    final edited = Course(id: id, title: title, body: body, userId: userId);
    final updated = await _apiService.updateCourse(id, edited);
    await _localDataSource.upsertCourse(updated);
    return updated;
  }

  /// Delete a course on the server, then remove it from the cache.
  Future<void> deleteCourse(int id) async {
    await _apiService.deleteCourse(id);
    await _localDataSource.removeCourse(id);
  }

  Future<DateTime?> lastSyncTime() => _localDataSource.lastSyncTime();

  void dispose() => _apiService.dispose();
}
