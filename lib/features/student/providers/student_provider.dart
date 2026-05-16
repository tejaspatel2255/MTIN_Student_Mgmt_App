import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../core/services/supabase_service.dart';

class StudentProvider extends ChangeNotifier {
  final SupabaseService _supabase = SupabaseService();

  Semester? _selectedSemester;
  Subject? _selectedSubject;
  List<Requirement> _requirements = [];
  bool _isLoading = false;

  Semester? get selectedSemester => _selectedSemester;
  Subject? get selectedSubject => _selectedSubject;
  List<Requirement> get requirements => _requirements;
  bool get isLoading => _isLoading;

  void setSemester(Semester semester) {
    _selectedSemester = semester;
    _selectedSubject = null;
    _requirements = [];
    notifyListeners();
  }

  void setSubject(Subject subject) {
    _selectedSubject = subject;
    fetchRequirements();
    notifyListeners();
  }

  Future<List<Semester>> fetchSemesters() async {
    try {
      final data = await _supabase.getSemesters();
      return data.map((json) => Semester.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching semesters: $e');
      rethrow;
    }
  }

  Future<List<Subject>> fetchSubjects() async {
    if (_selectedSemester == null) return [];
    try {
      final data = await _supabase.getSubjects(_selectedSemester!.id);
      return data.map((json) => Subject.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching subjects: $e');
      rethrow;
    }
  }

  Future<void> fetchRequirements() async {
    if (_selectedSubject == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _supabase.getRequirements(_selectedSubject!.id);
      _requirements = data.map((json) => Requirement.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching requirements: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
