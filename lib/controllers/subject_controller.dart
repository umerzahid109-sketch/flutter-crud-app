// lib/controllers/subject_controller.dart

import '../models/user_model.dart';

class SubjectController {
  SubjectController._();

  static List<SubjectModel> getSubjects() => const [
        SubjectModel(
          name: 'Mobile App Development',
          description:
              'An in-depth course covering cross-platform mobile application development '
              'using Flutter and Dart. Students will learn UI design principles, state '
              'management, API integration, and deployment strategies for Android and iOS platforms.',
          schedule: 'Monday & Wednesday — 10:00 AM to 11:30 AM\nRoom: CS-204',
          instructor: 'Dr. Ahmed Raza',
        ),
        SubjectModel(
          name: 'Software Re-engineering',
          description:
              'This course focuses on techniques for modernizing legacy software systems. '
              'Topics include code refactoring, design pattern adoption, reverse engineering, '
              'and migration strategies to ensure long-term maintainability and scalability.',
          schedule: 'Tuesday & Thursday — 12:00 PM to 1:30 PM\nRoom: CS-301',
          instructor: 'Prof. Sara Khan',
        ),
        SubjectModel(
          name: 'MIS',
          description:
              'Management Information Systems explores the role of information technology '
              'in organizational decision-making. Covers database management, ERP systems, '
              'business intelligence, and information security fundamentals.',
          schedule: 'Friday — 9:00 AM to 12:00 PM\nRoom: BBA-101',
          instructor: 'Mr. Tariq Malik',
        ),
      ];
}
