// lib/screens/courses_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../models/course_model.dart';
import '../state/course_provider.dart';
import '../state/course_view_state.dart';
import '../widgets/offline_banner.dart';
import 'course_detail_screen.dart';
import 'course_form_screen.dart';

class CoursesListScreen extends StatefulWidget {
  final AuthController authController;

  const CoursesListScreen({super.key, required this.authController});

  @override
  State<CoursesListScreen> createState() => _CoursesListScreenState();
}

class _CoursesListScreenState extends State<CoursesListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Trigger the first load after the first frame so the provider is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CourseProvider>();
      if (provider.state == CourseViewState.initial) {
        provider.loadCourses();
      }
    });
    _searchController.addListener(() {
      context.read<CourseProvider>().search(_searchController.text);
      // Rebuild so the clear (x) icon shows/hides with the field contents.
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _snack(String message, {required bool success}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _confirmDelete(Course course) async {
    final provider = context.read<CourseProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        title: const Text('Delete Course',
            style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete "${course.title}"?',
            style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Optimistic delete: the row disappears immediately; if the API call
    // fails the provider restores it and we surface the error here.
    final success = await provider.deleteCourse(course.id);
    if (success) {
      _snack('Course deleted', success: true);
    } else {
      _snack('Delete failed: ${provider.errorMessage ?? 'unknown error'}',
          success: false);
    }
  }

  void _openDetail(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourseDetailScreen(courseId: course.id),
      ),
    );
  }

  void _openAddForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CourseFormScreen()),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to logout?',
            style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await widget.authController.logout();
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    }
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
          // Offline indicator (only shown when data came from the cache).
          Consumer<CourseProvider>(
            builder: (_, provider, __) => provider.isOffline
                ? OfflineBanner(lastSync: provider.lastSync)
                : const SizedBox.shrink(),
          ),
          // Search bar.
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search courses...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          context.read<CourseProvider>().clearSearch();
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
            ),
          ),
          Expanded(
            child: Consumer<CourseProvider>(
              builder: (_, provider, __) => _buildBody(provider),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddForm,
        tooltip: 'Add Course',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(CourseProvider provider) {
    // First-load spinner (no data yet).
    if (provider.state == CourseViewState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Hard error with nothing cached to show.
    if (provider.state == CourseViewState.error) {
      return _ErrorView(
        message: provider.errorMessage ?? 'Something went wrong.',
        onRetry: () => provider.loadCourses(),
      );
    }

    final courses = provider.filteredCourses;
    final searching = provider.searchQuery.trim().isNotEmpty;

    // Empty state (either no data at all, or no search matches).
    if (courses.isEmpty) {
      return RefreshIndicator(
        onRefresh: provider.refresh,
        child: ListView(
          // ListView (not Center) so pull-to-refresh still works when empty.
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: _EmptyView(
                searching: searching,
                onAdd: _openAddForm,
              ),
            ),
          ],
        ),
      );
    }

    // Populated list with pull-to-refresh.
    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: courses.length,
        itemBuilder: (_, index) => _buildCourseCard(courses[index]),
      ),
    );
  }

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
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            course.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _openDetail(course);
            } else if (value == 'delete') {
              _confirmDelete(course);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'edit',
              child: Row(children: [
                Icon(Icons.edit, size: 20, color: Colors.blue),
                SizedBox(width: 8),
                Text('Edit'),
              ]),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(children: [
                Icon(Icons.delete, size: 20, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete'),
              ]),
            ),
          ],
        ),
        onTap: () => _openDetail(course),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final bool searching;
  final VoidCallback onAdd;

  const _EmptyView({required this.searching, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(searching ? Icons.search_off : Icons.school,
              size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            searching ? 'No matching courses' : 'No courses found',
            style: TextStyle(fontSize: 16, color: Colors.grey[400]),
          ),
          if (!searching) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Course'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              'Could not load courses',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
