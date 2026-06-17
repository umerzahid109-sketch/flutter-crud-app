// lib/state/course_provider.dart

import 'package:flutter/foundation.dart';

import '../data/repositories/course_repository.dart';
import '../models/course_model.dart';
import 'course_view_state.dart';

/// Holds all UI state for the courses feature and exposes intent-style methods
/// to the screens. This is the "State Management" layer: it talks to the
/// [CourseRepository] for data and never performs HTTP or storage itself, so
/// business logic stays out of the widgets.
class CourseProvider extends ChangeNotifier {
  final CourseRepository _repository;

  CourseProvider({CourseRepository? repository})
      : _repository = repository ?? CourseRepository();

  // ---- State ----------------------------------------------------------------
  CourseViewState _state = CourseViewState.initial;
  List<Course> _courses = <Course>[];
  String _searchQuery = '';
  String? _errorMessage;

  /// True when the data currently shown was loaded from the offline cache.
  bool _isOffline = false;
  DateTime? _lastSync;

  // ---- Getters --------------------------------------------------------------
  CourseViewState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isOffline => _isOffline;
  DateTime? get lastSync => _lastSync;
  String get searchQuery => _searchQuery;

  bool get isLoading => _state == CourseViewState.loading;
  bool get isEmpty => _state == CourseViewState.empty;
  bool get hasError => _state == CourseViewState.error;

  /// All loaded courses (unfiltered).
  List<Course> get courses => List.unmodifiable(_courses);

  /// Courses after applying the active search query (what the list renders).
  List<Course> get filteredCourses {
    if (_searchQuery.trim().isEmpty) return List.unmodifiable(_courses);
    final q = _searchQuery.toLowerCase();
    return _courses
        .where((c) =>
            c.title.toLowerCase().contains(q) ||
            c.body.toLowerCase().contains(q))
        .toList(growable: false);
  }

  // ---- Loading --------------------------------------------------------------

  /// Initial / full load. Shows a full-screen spinner while fetching.
  Future<void> loadCourses() async {
    _state = CourseViewState.loading;
    _errorMessage = null;
    notifyListeners();
    await _fetch();
  }

  /// Pull-to-refresh. Keeps the current list visible (no full-screen spinner)
  /// while the refresh runs.
  Future<void> refresh() => _fetch();

  Future<void> _fetch() async {
    try {
      final result = await _repository.getCourses();
      _courses = result.courses;
      _isOffline = result.fromCache;
      _lastSync = result.lastSync;
      _errorMessage = null;
      _state =
          _courses.isEmpty ? CourseViewState.empty : CourseViewState.loaded;
    } catch (e) {
      // Network failed AND there was no cache to show.
      _errorMessage = _readableError(e);
      _state =
          _courses.isEmpty ? CourseViewState.error : CourseViewState.loaded;
    }
    notifyListeners();
  }

  // ---- Search ---------------------------------------------------------------

  void search(String query) {
    _searchQuery = query;
    // Recompute emptiness against the active filter so the empty-state UI is
    // accurate while searching.
    notifyListeners();
  }

  void clearSearch() {
    if (_searchQuery.isEmpty) return;
    _searchQuery = '';
    notifyListeners();
  }

  // ---- Create (optimistic) --------------------------------------------------

  /// Optimistically inserts a temporary course at the top, then reconciles with
  /// the server response. Rolls the insert back if the request fails.
  Future<bool> createCourse(String title, String body) async {
    if (title.trim().isEmpty || body.trim().isEmpty) {
      _errorMessage = 'Title and description cannot be empty.';
      notifyListeners();
      return false;
    }

    // Temporary negative id guarantees no clash with server ids.
    final tempId = -DateTime.now().millisecondsSinceEpoch;
    final optimistic =
        Course(id: tempId, title: title, body: body, userId: 1);

    _courses = [optimistic, ..._courses];
    _state = CourseViewState.loaded;
    notifyListeners();

    try {
      final created =
          await _repository.createCourse(title: title, body: body);
      // Replace the temporary entry with the real one from the server.
      final index = _courses.indexWhere((c) => c.id == tempId);
      if (index != -1) {
        _courses[index] = created;
      }
      notifyListeners();
      return true;
    } catch (e) {
      // Roll back the optimistic insert.
      _courses.removeWhere((c) => c.id == tempId);
      _state =
          _courses.isEmpty ? CourseViewState.empty : CourseViewState.loaded;
      _errorMessage = _readableError(e);
      notifyListeners();
      return false;
    }
  }

  // ---- Update (optimistic) --------------------------------------------------

  Future<bool> updateCourse(int id, String title, String body) async {
    if (title.trim().isEmpty || body.trim().isEmpty) {
      _errorMessage = 'Title and description cannot be empty.';
      notifyListeners();
      return false;
    }

    final index = _courses.indexWhere((c) => c.id == id);
    if (index == -1) return false;

    final previous = _courses[index];
    // Apply the edit immediately.
    _courses[index] = previous.copyWith(title: title, body: body);
    notifyListeners();

    try {
      final updated =
          await _repository.updateCourse(id: id, title: title, body: body);
      final i = _courses.indexWhere((c) => c.id == id);
      if (i != -1) _courses[i] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      // Roll back to the pre-edit value.
      final i = _courses.indexWhere((c) => c.id == id);
      if (i != -1) _courses[i] = previous;
      _errorMessage = _readableError(e);
      notifyListeners();
      return false;
    }
  }

  // ---- Delete (optimistic) --------------------------------------------------

  Future<bool> deleteCourse(int id) async {
    final index = _courses.indexWhere((c) => c.id == id);
    if (index == -1) return false;

    final removed = _courses[index];
    // Remove from the UI right away for a snappy feel.
    _courses.removeAt(index);
    _state =
        _courses.isEmpty ? CourseViewState.empty : CourseViewState.loaded;
    notifyListeners();

    try {
      await _repository.deleteCourse(id);
      return true;
    } catch (e) {
      // Restore the deleted course at its original position.
      final insertAt = index <= _courses.length ? index : _courses.length;
      _courses.insert(insertAt, removed);
      _state = CourseViewState.loaded;
      _errorMessage = _readableError(e);
      notifyListeners();
      return false;
    }
  }

  // ---- Helpers --------------------------------------------------------------

  Course? courseById(int id) {
    final index = _courses.indexWhere((c) => c.id == id);
    return index == -1 ? null : _courses[index];
  }

  String _readableError(Object e) {
    final text = e.toString();
    return text.replaceFirst('ApiException: ', '').replaceFirst('Exception: ', '');
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}
