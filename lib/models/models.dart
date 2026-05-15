import 'package:uuid/uuid.dart';

class StudentProfile {
  final String id;
  final String studentId;
  final String fullName;
  final String? email;

  StudentProfile({
    required this.id,
    required this.studentId,
    required this.fullName,
    this.email,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: json['id'],
      studentId: json['student_id'],
      fullName: json['full_name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'full_name': fullName,
      'email': email,
    };
  }
}

class Semester {
  final String id;
  final String name;

  Semester({required this.id, required this.name});

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      id: json['id'].toString(),
      name: json['name'],
    );
  }
}

class Subject {
  final String id;
  final String code;
  final String name;
  final String semesterId;

  Subject({
    required this.id,
    required this.code,
    required this.name,
    required this.semesterId,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'].toString(),
      code: json['code'],
      name: json['name'],
      semesterId: json['semester_id'].toString(),
    );
  }
}

class Requirement {
  final String id;
  final String subjectId;
  final String title;
  final String description;
  final String section; // A or B
  final String? category;
  final String? superCategory;

  Requirement({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.description,
    required this.section,
    this.category,
    this.superCategory,
  });

  factory Requirement.fromJson(Map<String, dynamic> json) {
    return Requirement(
      id: json['id'].toString(),
      subjectId: json['subject_id'].toString(),
      title: json['title'],
      description: json['description'],
      section: json['section'] ?? 'A',
      category: json['category'],
      superCategory: json['super_category'],
    );
  }
}

enum SubmissionStatus { draft, submitted, approved, rejected }

class Submission {
  final String id;
  final String studentId;
  final String requirementId;
  final String content;
  final SubmissionStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Submission({
    required this.id,
    required this.studentId,
    required this.requirementId,
    required this.content,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['id'],
      studentId: json['student_id'],
      requirementId: json['requirement_id'].toString(),
      content: json['content'],
      status: SubmissionStatus.values.byName(json['status']),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'requirement_id': requirementId,
      'content': content,
      'status': status.name,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}

class BaselineSurvey {
  final String id;
  final String studentId;
  final String subjectId;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime updatedAt;

  BaselineSurvey({
    required this.id,
    required this.studentId,
    required this.subjectId,
    required this.data,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BaselineSurvey.fromJson(Map<String, dynamic> json) {
    return BaselineSurvey(
      id: json['id'].toString(),
      studentId: json['student_id'].toString(),
      subjectId: json['subject_id'].toString(),
      data: json['data'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
