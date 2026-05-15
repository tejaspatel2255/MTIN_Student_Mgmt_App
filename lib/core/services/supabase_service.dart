import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/constants.dart';
import '../../models/models.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final client = Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  // Auth
  Future<AuthResponse> signInWithId(String studentId) async {
    // Note: This is a placeholder for custom logic. 
    // In a real app, you'd use a custom function or email/password.
    // For now, we'll assume students use their ID as a password or a specific email pattern.
    return await client.auth.signInWithPassword(
      email: '$studentId@student.edu', // Mocking email for Supabase Auth
      password: studentId,
    );
  }

  // Data
  Future<List<Map<String, dynamic>>> getSemesters() async {
    return await client.from('semesters').select();
  }

  Future<List<Map<String, dynamic>>> getSubjects(String semesterId) async {
    return await client.from('subjects').select().eq('semester_id', semesterId);
  }

  Future<List<Map<String, dynamic>>> getRequirements(String subjectId) async {
    return await client.from('requirements').select().eq('subject_id', subjectId);
  }

  Future<void> upsertSubmission(Map<String, dynamic> submission) async {
    await client.from('submissions').upsert(submission);
  }

  // Baseline Surveys
  Future<List<BaselineSurvey>> getBaselineSurveys(String studentId, String subjectId) async {
    final response = await client
        .from('baseline_surveys')
        .select()
        .eq('student_id', studentId)
        .eq('subject_id', subjectId)
        .order('created_at', ascending: false);
    return (response as List).map((json) => BaselineSurvey.fromJson(json)).toList();
  }

  Future<void> createBaselineSurvey(Map<String, dynamic> data) async {
    await client.from('baseline_surveys').insert(data);
  }

  Future<void> updateBaselineSurvey(String id, Map<String, dynamic> data) async {
    await client.from('baseline_surveys').update(data).eq('id', id);
  }

  Future<void> deleteBaselineSurvey(String id) async {
    await client.from('baseline_surveys').delete().eq('id', id);
  }
}
