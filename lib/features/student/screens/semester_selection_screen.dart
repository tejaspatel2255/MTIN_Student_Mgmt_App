import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../../../core/constants/constants.dart';
import '../../../models/models.dart';
import 'subject_selection_screen.dart';

class SemesterSelectionScreen extends StatelessWidget {
  const SemesterSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock semesters
    final List<Semester> semesters = [
      Semester(id: '5', name: '5th Semester'),
      Semester(id: '7', name: '7th Semester'),
      Semester(id: '8', name: '8th Semester'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Semester'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Semester>>(
        future: context.read<StudentProvider>().fetchSemesters(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final semesters = snapshot.data ?? [];
          
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Which semester are you in?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select your current academic period to see your requirements.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView.separated(
                    itemCount: semesters.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final semester = semesters[index];
                      return SemesterCard(
                        semester: semester,
                        onTap: () {
                          context.read<StudentProvider>().setSemester(semester);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SubjectSelectionScreen()),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SemesterCard extends StatelessWidget {
  final Semester semester;
  final VoidCallback onTap;

  const SemesterCard({super.key, required this.semester, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surface,
              AppColors.surface.withOpacity(0.5),
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calendar_today, color: AppColors.primary),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                semester.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
