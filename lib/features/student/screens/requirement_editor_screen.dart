import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constants.dart';
import '../../../models/models.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/services/supabase_service.dart';

class RequirementEditorScreen extends StatefulWidget {
  final Requirement requirement;

  const RequirementEditorScreen({super.key, required this.requirement});

  @override
  State<RequirementEditorScreen> createState() => _RequirementEditorScreenState();
}

class _RequirementEditorScreenState extends State<RequirementEditorScreen> {
  final TextEditingController _contentController = TextEditingController();
  bool _isSaving = false;

  void _saveDraft() async {
    final studentId = context.read<AuthProvider>().currentUser?.studentId;
    if (studentId == null) return;

    setState(() => _isSaving = true);
    try {
      await SupabaseService().upsertSubmission({
        'student_id': studentId,
        'requirement_id': widget.requirement.id,
        'content': _contentController.text,
        'status': 'draft',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Draft saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving draft: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _submitFinal() async {
    final studentId = context.read<AuthProvider>().currentUser?.studentId;
    if (studentId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Submission'),
        content: const Text('Are you sure you want to submit? You won\'t be able to edit after submission.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Submit')),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isSaving = true);
      try {
        await SupabaseService().upsertSubmission({
          'student_id': studentId,
          'requirement_id': widget.requirement.id,
          'content': _contentController.text,
          'status': 'submitted',
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Requirement submitted successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error submitting: $e'), backgroundColor: AppColors.error),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.requirement.title),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else ...[
            TextButton(
              onPressed: _saveDraft,
              child: const Text('Save Draft', style: TextStyle(color: AppColors.textSecondary)),
            ),
            const SizedBox(width: 8),
          ]
        ],
      ),
      body: Column(
        children: [
          // Guidelines / Info Area
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.primary.withOpacity(0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Instructions:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.requirement.description,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          
          // Editor Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Start writing your requirement here...',
                  filled: false,
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
          ),
          
          // Bottom Actions
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              onPressed: _isSaving ? null : _submitFinal,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Text('Final Submission'),
            ),
          ),
        ],
      ),
    );
  }
}
