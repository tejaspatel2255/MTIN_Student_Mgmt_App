import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../../../core/constants/constants.dart';
import '../../../models/models.dart';
import './pdf_viewer_screen.dart';
import 'requirement_editor_screen.dart';
import 'baseline_survey_list_screen.dart';

class RequirementListScreen extends StatefulWidget {
  const RequirementListScreen({super.key});

  @override
  State<RequirementListScreen> createState() => _RequirementListScreenState();
}

class _RequirementListScreenState extends State<RequirementListScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure data is fetched if the list is empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<StudentProvider>().requirements.isEmpty) {
        context.read<StudentProvider>().fetchRequirements();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final subject = context.watch<StudentProvider>().selectedSubject;
    final requirements = context.watch<StudentProvider>().requirements;
    final isLoading = context.watch<StudentProvider>().isLoading;

    // Group requirements: superCategory -> category -> List<Requirement>
    final Map<String, Map<String, List<Requirement>>> grouped = {};
    for (var req in requirements) {
      if (req.superCategory == null) continue;
      final superCat = req.superCategory!;
      final category = req.category ?? 'Uncategorized';
      if (!grouped.containsKey(superCat)) grouped[superCat] = {};
      if (!grouped[superCat]!.containsKey(category)) grouped[superCat]![category] = [];
      grouped[superCat]![category]!.add(req);
    }

    final superCategories = grouped.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text(subject?.code ?? 'Requirements'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<StudentProvider>().fetchRequirements(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<StudentProvider>().fetchRequirements(),
        child: isLoading && requirements.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Clinical Postings',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text('Select a posting to view sections.', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: requirements.isEmpty && !isLoading
                          ? _buildEmptyState()
                          : ListView.builder(
                              itemCount: superCategories.length,
                              itemBuilder: (context, index) {
                                final superCat = superCategories[index];
                                final subGroups = grouped[superCat]!;
                                final sortedCategories = subGroups.keys.toList();
                                
                                sortedCategories.sort((a, b) {
                                  if (a.startsWith('III')) return 1;
                                  if (b.startsWith('III')) return -1;
                                  final numA = int.tryParse(a.split('.')[0]) ?? 0;
                                  final numB = int.tryParse(b.split('.')[0]) ?? 0;
                                  return numA.compareTo(numB);
                                });

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(color: AppColors.primary.withOpacity(0.1)),
                                  ),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                    child: ExpansionTile(
                                      title: Text(superCat, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
                                      leading: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                                      children: sortedCategories.map((catName) {
                                        final items = subGroups[catName]!;
                                        return ExpansionTile(
                                          title: Text(catName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                          children: items.map((req) => Padding(
                                            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                                            child: RequirementCard(
                                              requirement: req,
                                              onTap: () {
                                                Navigator.push(context, MaterialPageRoute(builder: (_) => RequirementEditorScreen(requirement: req)));
                                              },
                                            ),
                                          )).toList(),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 16),
                    _buildSurveyShortcut(context),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No requirements found.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<StudentProvider>().fetchRequirements(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSurveyShortcut(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: AppColors.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BaselineSurveyListScreen())),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.assignment_rounded, color: Colors.white, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Baseline Survey', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Community Health Nursing - I', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class RequirementCard extends StatelessWidget {
  final Requirement requirement;
  final VoidCallback onTap;
  const RequirementCard({super.key, required this.requirement, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text('Section ${requirement.section}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(requirement.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(requirement.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.edit_note, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
