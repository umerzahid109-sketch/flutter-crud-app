// lib/enums/app_enums.dart

enum Gender { male, female, other, preferNotToSay }

extension GenderExtension on Gender {
  String get label {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
      case Gender.preferNotToSay:
        return 'Prefer not to say';
    }
  }
}

enum AuthState { idle, loading, success, error }

enum FormFieldType { name, email, password, confirmPassword }
