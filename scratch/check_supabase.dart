import 'package:supabase/supabase.dart';

void main() async {
  final client = SupabaseClient(
    'https://taxyctrqxdnefyzrixfq.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRheHljdHJxeGRuZWZ5enJpeGZxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg4MjAyNTYsImV4cCI6MjA5NDM5NjI1Nn0.i--Bd4CpCSyBgDmADPlEToJ99bFEM_NyPRqSVTcodPw',
  );

  print('Fetching semesters...');
  final semesters = await client.from('semesters').select();
  print('Semesters: $semesters');

  if (semesters.isNotEmpty) {
    final firstSemesterId = semesters[0]['id'].toString(); // Convert to string
    print('Fetching subjects for semester $firstSemesterId (as string)...');
    final subjects = await client.from('subjects').select().eq('semester_id', firstSemesterId);
    print('Subjects: $subjects');

    if (subjects.isNotEmpty) {
      final firstSubjectId = subjects[0]['id'];
      print('Fetching requirements for subject $firstSubjectId...');
      final requirements = await client.from('requirements').select().eq('subject_id', firstSubjectId);
      print('Requirements count: ${requirements.length}');
      if (requirements.isNotEmpty) {
        print('First requirement: ${requirements[0]}');
      }
    }
  } else {
    print('No semesters found!');
  }
}
