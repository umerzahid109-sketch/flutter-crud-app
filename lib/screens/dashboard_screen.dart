// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../controllers/subject_controller.dart';
import '../models/user_model.dart';
import 'detail_screen.dart';
import 'courses_list_screen.dart';

class DashboardScreen extends StatelessWidget {
  final AuthController authController;

  const DashboardScreen({super.key, required this.authController});

  Future<void> _logout(BuildContext context) async {
    await authController.logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = authController.currentUser!;
    final subjects = SubjectController.getSubjects();
    final initials = user.fullName
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      body: SafeArea(
        child: Column(
          children: [
            // Top Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF0D1526),
                border: Border(
                  bottom: BorderSide(color: Color(0xFF1A2340), width: 1),
                ),
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2962FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${user.fullName.split(' ').first}! 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user.email,
                          style: TextStyle(
                              color: Colors.blue.shade200, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Logout
                  IconButton(
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    tooltip: 'Logout',
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Actions
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CoursesListScreen(
                                  authController: authController,
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.school),
                            label: const Text('Manage Courses'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'My Subjects',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${subjects.length} subjects enrolled this semester',
                      style:
                          TextStyle(color: Colors.blue.shade200, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.separated(
                        itemCount: subjects.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final subject = subjects[index];
                          return _SubjectCard(
                            subject: subject,
                            index: index,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(
                                  subject: subject,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final SubjectModel subject;
  final int index;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.subject,
    required this.index,
    required this.onTap,
  });

  static const _colors = [
    Color(0xFF2962FF),
    Color(0xFF00897B),
    Color(0xFF6A1B9A),
  ];

  static const _icons = [
    Icons.phone_android,
    Icons.code,
    Icons.business_center,
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[index % _colors.length];
    final icon = _icons[index % _icons.length];

    return Material(
      color: const Color(0xFF0D1526),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1A2340), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.4)),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subject.instructor,
                      style:
                          TextStyle(color: Colors.blue.shade200, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.blue.shade200),
            ],
          ),
        ),
      ),
    );
  }
}
