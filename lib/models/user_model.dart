// lib/models/user_model.dart

import '../enums/app_enums.dart';

class UserModel {
  final String fullName;
  final String email;
  final Gender gender;

  const UserModel({
    required this.fullName,
    required this.email,
    required this.gender,
  });

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'email': email,
        'gender': gender.index,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        fullName: map['fullName'] as String,
        email: map['email'] as String,
        gender: Gender.values[map['gender'] as int],
      );
}

class SubjectModel {
  final String name;
  final String description;
  final String schedule;
  final String instructor;

  const SubjectModel({
    required this.name,
    required this.description,
    required this.schedule,
    required this.instructor,
  });
}
