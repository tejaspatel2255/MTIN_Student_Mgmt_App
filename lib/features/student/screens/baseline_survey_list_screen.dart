import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../models/models.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/student_provider.dart';
import 'baseline_survey_form_screen.dart';

class BaselineSurveyListScreen extends StatefulWidget {
  const BaselineSurveyListScreen({super.key});

  @override
  State<BaselineSurveyListScreen> createState() => _BaselineSurveyListScreenState();
}

class _BaselineSurveyListScreenState extends State<BaselineSurveyListScreen> {
  List<BaselineSurvey> _surveys = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSurveys();
  }

  Future<void> _loadSurveys() async {
    final studentId = context.read<AuthProvider>().currentUser?.id;
    final subjectId = context.read<StudentProvider>().selectedSubject?.id;
    if (studentId == null || subjectId == null) return;

    setState(() => _isLoading = true);
    try {
      final surveys = await SupabaseService().getBaselineSurveys(studentId, subjectId);
      setState(() => _surveys = surveys);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading surveys: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baseline Surveys'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _surveys.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.assignment_outlined, size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      const Text('No surveys submitted yet', style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const BaselineSurveyFormScreen()),
                          );
                          _loadSurveys();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Start First Survey'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _surveys.length,
                  itemBuilder: (context, index) {
                    final survey = _surveys[index];
                    final date = survey.createdAt.toLocal().toString().split('.')[0];
                    final headName = survey.data['head_of_family_name'] ?? 'Unknown Family';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(headName),
                        subtitle: Text('Submitted on: $date'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BaselineSurveyFormScreen(survey: survey),
                            ),
                          );
                          _loadSurveys();
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: _surveys.isNotEmpty
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BaselineSurveyFormScreen()),
                );
                _loadSurveys();
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
