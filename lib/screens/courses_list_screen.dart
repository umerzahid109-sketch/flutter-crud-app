// lib/screens/courses_list_screen.dart

import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../controllers/course_controller.dart';
import '../models/course_model.dart';
import 'course_form_screen.dart';
import 'course_detail_screen.dart';

class CoursesListScreen extends StatefulWidget {
  final AuthController authController;

  const CoursesListScreen({
    Key? key,
    required this.authController,
  }) : super(key: key);

  @override
  State<CoursesListScreen> createState() => _CoursesListScreenState();
}

class _CoursesListScreenState extends State<CoursesListScreen> {
  late CourseController _courseController;
  final TextEditingController _searchController = TextEditingController();
  List<Course> _filteredCourses = [];

  @override
  void initState() {
    super.initState();
    _courseController = CourseController();
    _fetchCourses();

    // Listen to search changes
    _searchController.addListener(_onSearchChanged);
  }

  /// Fetch courses from API
  void _fetchCourses() {
    _courseController.fetchCourses().then((_) {
      setState(() {
        _filteredCourses = _courseController.courses;
      });
    });
  }

  /// Handle search functionality
  void _onSearchChanged() {
    setState(() {
      _filteredCourses =
          _courseController.searchCourses(_searchController.text);
    });
  }

  /// Show delete confirmation dialog
  void _showDeleteDialog(Course course) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1F3A),
          title: const Text(
            'Delete Course',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to delete "${course.title}"?',
            style: const TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteCourse(course.id);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Delete course
  void _deleteCourse(int courseId) async {
    final success = await _courseController.deleteCourse(courseId);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _filteredCourses =
              _courseController.searchCourses(_searchController.text);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${_courseController.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Navigate to course detail
  void _navigateToCourseDetail(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(
          course: course,
          courseController: _courseController,
          onUpdate: () {
            setState(() {
              _filteredCourses =
                  _courseController.searchCourses(_searchController.text);
            });
          },
        ),
      ),
    );
  }

  /// Navigate to course form for adding new course
  void _navigateToAddCourse() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseFormScreen(
          courseController: _courseController,
          onSave: () {
            setState(() {
              _filteredCourses =
                  _courseController.searchCourses(_searchController.text);
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  /// Logout user
  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1F3A),
          title: const Text(
            'Logout',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () {
                widget.authController.logout();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search courses...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          // Courses List
          Expanded(
            child: _courseController.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _filteredCourses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.school,
                              size: 64,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'No courses found'
                                  : 'No matching courses',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[400],
                              ),
                            ),
                            if (_searchController.text.isEmpty)
                              const SizedBox(height: 32),
                            if (_searchController.text.isEmpty)
                              ElevatedButton.icon(
                                onPressed: _navigateToAddCourse,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Course'),
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredCourses.length,
                        itemBuilder: (context, index) {
                          final course = _filteredCourses[index];
                          return _buildCourseCard(course);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddCourse,
        tooltip: 'Add Course',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Build course list card
  Widget _buildCourseCard(Course course) {
    return Card(
      color: const Color(0xFF1A1F3A),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          course.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          course.body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
        trailing: PopupMenuButton(
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.edit, size: 20, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
              onTap: () => _navigateToCourseDetail(course),
            ),
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
              onTap: () => _showDeleteDialog(course),
            ),
          ],
        ),
        onTap: () => _navigateToCourseDetail(course),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _courseController.dispose();
    super.dispose();
  }
}
