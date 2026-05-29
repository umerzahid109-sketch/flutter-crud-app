// lib/screens/detail_screen.dart

import 'package:flutter/material.dart';
import '../models/user_model.dart';

class DetailScreen extends StatelessWidget {
  final SubjectModel subject;

  const DetailScreen({super.key, required this.subject});

  static const _subjectColors = {
    'Mobile App Development': Color(0xFF2962FF),
    'Software Re-engineering': Color(0xFF00897B),
    'MIS': Color(0xFF6A1B9A),
  };

  static const _subjectIcons = {
    'Mobile App Development': Icons.phone_android,
    'Software Re-engineering': Icons.code,
    'MIS': Icons.business_center,
  };

  @override
  Widget build(BuildContext context) {
    final color = _subjectColors[subject.name] ?? const Color(0xFF2962FF);
    final icon = _subjectIcons[subject.name] ?? Icons.book;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      body: CustomScrollView(
        slivers: [
          // Banner / App Bar
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF0D1526),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.9),
                      color.withOpacity(0.4),
                      const Color(0xFF0A0F1E),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3), width: 2),
                        ),
                        child: Icon(icon, size: 40, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          subject.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Instructor chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: color.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_outline, color: color, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          subject.instructor,
                          style: TextStyle(color: color, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description card
                  _InfoCard(
                    title: 'Course Overview',
                    icon: Icons.info_outline,
                    color: color,
                    child: Text(
                      subject.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Schedule card
                  _InfoCard(
                    title: 'Schedule',
                    icon: Icons.schedule,
                    color: color,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: subject.schedule.split('\n').map((line) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Icon(
                                line.startsWith('Room')
                                    ? Icons.room_outlined
                                    : Icons.access_time,
                                size: 15,
                                color: color,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                line,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1526),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1A2340), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF1A2340), height: 1),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
