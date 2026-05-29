// lib/controllers/course_controller.dart

import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../services/api_service.dart';

/// Enum to represent different states during API operations
enum ApiState { idle, loading, success, error }

/// Controller class to manage course data and API operations
/// This class handles all business logic for CRUD operations
class CourseController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State management
  ApiState _state = ApiState.idle;
  String _errorMessage = '';
  List<Course> _courses = [];
  Course? _selectedCourse;

  // Getters
  ApiState get state => _state;
  String get errorMessage => _errorMessage;
  List<Course> get courses => _courses;
  Course? get selectedCourse => _selectedCourse;
  bool get isLoading => _state == ApiState.loading;

  /// Fetch all courses from API
  /// Updates state during the process
  Future<void> fetchCourses() async {
    try {
      _setLoading();
      _courses = await _apiService.fetchCourses();
      _setSuccess();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Fetch a single course by ID
  Future<void> fetchCourseById(int id) async {
    try {
      _setLoading();
      _selectedCourse = await _apiService.fetchCourseById(id);
      _setSuccess();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Create a new course
  /// Adds the new course to the list
  Future<bool> createCourse(String title, String body) async {
    try {
      _setLoading();

      // Validate input
      if (title.isEmpty || body.isEmpty) {
        _setError('Title and body cannot be empty');
        return false;
      }

      final newCourse = Course(
        id: 0, // Server will assign ID
        title: title,
        body: body,
        userId: 1,
      );

      final createdCourse = await _apiService.createCourse(newCourse);
      _courses.add(createdCourse);
      _setSuccess();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Update an existing course
  /// Updates the course in the list
  Future<bool> updateCourse(int id, String title, String body) async {
    try {
      _setLoading();

      // Validate input
      if (title.isEmpty || body.isEmpty) {
        _setError('Title and body cannot be empty');
        return false;
      }

      final updatedCourse = Course(
        id: id,
        title: title,
        body: body,
        userId: 1,
      );

      final result = await _apiService.updateCourse(id, updatedCourse);

      // Update in local list
      final index = _courses.indexWhere((course) => course.id == id);
      if (index != -1) {
        _courses[index] = result;
      }

      _setSuccess();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Delete a course by ID
  /// Removes the course from the list
  Future<bool> deleteCourse(int id) async {
    try {
      _setLoading();

      final success = await _apiService.deleteCourse(id);

      if (success) {
        // Remove from local list
        _courses.removeWhere((course) => course.id == id);
        _setSuccess();
        return true;
      } else {
        _setError('Failed to delete course');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Search courses by title (local search)
  List<Course> searchCourses(String query) {
    if (query.isEmpty) {
      return _courses;
    }
    return _courses
        .where((course) =>
            course.title.toLowerCase().contains(query.toLowerCase()) ||
            course.body.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Clear selected course
  void clearSelectedCourse() {
    _selectedCourse = null;
    notifyListeners();
  }

  // Private helper methods

  /// Set loading state
  void _setLoading() {
    _state = ApiState.loading;
    _errorMessage = '';
    notifyListeners();
  }

  /// Set success state
  void _setSuccess() {
    _state = ApiState.success;
    _errorMessage = '';
    notifyListeners();
  }

  /// Set error state
  void _setError(String message) {
    _state = ApiState.error;
    _errorMessage = message;
    notifyListeners();
  }

  /// Clean up resources
  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
