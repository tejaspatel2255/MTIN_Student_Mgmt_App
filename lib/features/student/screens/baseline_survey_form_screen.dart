import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../models/models.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/student_provider.dart';

class BaselineSurveyFormScreen extends StatefulWidget {
  final BaselineSurvey? survey;
  const BaselineSurveyFormScreen({super.key, this.survey});

  @override
  State<BaselineSurveyFormScreen> createState() => _BaselineSurveyFormScreenState();
}

class _BaselineSurveyFormScreenState extends State<BaselineSurveyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _formData = {};
  Map<String, dynamic> _formStructure = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  Future<void> _loadForm() async {
    try {
      final String response = await rootBundle.loadString('assets/baseline_survey_form.json');
      final data = await json.decode(response);
      setState(() {
        _formStructure = data;
        _formData = widget.survey?.data ?? {};
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading form: $e');
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    final studentId = context.read<AuthProvider>().currentUser?.id;
    final subjectId = context.read<StudentProvider>().selectedSubject?.id;
    if (studentId == null || subjectId == null) return;

    setState(() => _isSaving = true);
    try {
      if (widget.survey == null) {
        await SupabaseService().createBaselineSurvey({'student_id': studentId, 'subject_id': subjectId, 'data': _formData});
      } else {
        await SupabaseService().updateBaselineSurvey(widget.survey!.id, {'data': _formData, 'updated_at': DateTime.now().toIso8601String()});
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved Successfully'), backgroundColor: AppColors.success));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _fieldLabel(String label) {
    return Padding(padding: const EdgeInsets.only(top: 12, bottom: 4), child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)));
  }

  Widget _radioGroup(String label, List<String> options, String groupValue, ValueChanged<String> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _fieldLabel(label),
      ...options.map((opt) => RadioListTile<String>(
        title: Text(opt),
        value: opt,
        groupValue: groupValue,
        dense: true,
        onChanged: (val) => onChanged(val!),
      )),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final sections = _formStructure['sections'] as List;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.survey == null ? 'New Baseline Survey' : 'Edit Baseline Survey'),
        actions: [
          if (_isSaving) const Center(child: Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))))
          else IconButton(icon: const Icon(Icons.save), onPressed: _saveForm),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            ...sections.map((section) => _buildSection(section)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveForm,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
              child: const Text('SUBMIT FORM', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(_formStructure['institution'] ?? '', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(_formStructure['campus'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const Divider(color: Colors.white24),
            Text(_formStructure['subject'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(Map<String, dynamic> section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(section['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
        ),
        ...(section['fields'] as List).map((field) => _buildField(field)),
      ],
    );
  }

  Widget _buildField(Map<String, dynamic> field) {
    final type = field['type'];
    final id = field['id'];
    final label = field['label'] ?? '';

    void updateValue(dynamic val) {
      if (field['onChanged'] != null) {
        field['onChanged'](val);
      } else {
        setState(() => _formData[id] = val);
      }
    }

    switch (type) {
      case 'text':
      case 'number':
      case 'tel':
      case 'textarea':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: TextFormField(
            initialValue: (field['onChanged'] != null ? field['initialValue'] : _formData[id])?.toString(),
            maxLines: type == 'textarea' ? 3 : 1,
            keyboardType: type == 'number' ? TextInputType.number : (type == 'tel' ? TextInputType.phone : TextInputType.text),
            decoration: InputDecoration(
              labelText: label, 
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            onChanged: updateValue,
          ),
        );

      case 'dropdown':
        final options = field['options'] as List;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            value: (field['onChanged'] != null ? field['initialValue'] : _formData[id])?.toString(),
            decoration: InputDecoration(
              labelText: label, 
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            items: options.map((opt) => DropdownMenuItem<String>(
              value: opt.toString(), 
              child: Text(opt.toString(), style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis)
            )).toList(),
            onChanged: updateValue,
          ),
        );

      case 'radio':
      case 'yes_no':
      case 'checkbox_yn':
        final options = field['options'] ?? ['Yes', 'No'];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              ...options.map((opt) => RadioListTile<String>(
                title: Text(opt is Map ? opt['label'] : opt, style: const TextStyle(fontSize: 14)),
                value: opt is Map ? opt['value'] : opt,
                dense: true,
                contentPadding: EdgeInsets.zero,
                groupValue: (field['onChanged'] != null ? field['initialValue'] : _formData[id]),
                onChanged: updateValue,
              )),
              if (field['has_text_input'] == true)
                _buildField({'id': '${id}_extra', 'label': field['text_label'] ?? 'Specify', 'type': 'text'}),
              if (field['conditional_fields'] != null && _formData[id] != null)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    children: ((field['conditional_fields'][_formData[id]] ?? []) as List).map((f) => _buildField(f)).toList(),
                  ),
                ),
            ],
          ),
        );

      case 'radio_with_subcaste':
        return Column(children: [
          _buildField({...field, 'type': 'radio'}),
          if (_formData[id] == 'Any Other')
            _buildField({'id': '${id}_sub', 'label': field['sub_field_label'], 'type': 'text'}),
        ]);

      case 'yes_no_with_reason':
        return Column(children: [
          _buildField({...field, 'type': 'yes_no'}),
          if (_formData[id] == 'No' || (id == 'breeding_places' && _formData[id] == 'Yes'))
            _buildField({'id': '${id}_reason', 'label': field['reason_label'] ?? 'State reasons', 'type': 'textarea'}),
        ]);

      case 'yes_no_with_table':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildField({...field, 'type': 'yes_no'}),
          if (_formData[id] == 'Yes') ...[
            if (field['sub_questions'] != null)
              ...(field['sub_questions'] as List).map((sq) => _buildField(sq)),
            _buildTableField({...field, 'id': '${id}_table', 'label': 'Details', 'type': 'table'}),
          ]
        ]);

      case 'checkbox':
        final options = field['options'] as List;
        final List selected = (field['onChanged'] != null ? field['initialValue'] : _formData[id]) ?? [];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              ...options.map((opt) => CheckboxListTile(
                title: Text(opt, style: const TextStyle(fontSize: 14)),
                value: selected.contains(opt),
                dense: true,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) {
                  if (val == true) selected.add(opt); else selected.remove(opt);
                  updateValue(selected);
                },
              )),
            ],
          ),
        );

      case 'checkbox_with_skills':
        final languages = field['languages'] as List;
        return Column(children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ...languages.map((lang) {
            final langId = lang['id'];
            _formData[langId] ??= {'selected': false, 'skills': []};
            return Column(children: [
              CheckboxListTile(
                title: Text(lang['label']),
                value: _formData[langId]['selected'],
                onChanged: (v) => setState(() => _formData[langId]['selected'] = v),
              ),
              if (_formData[langId]['selected'] == true) ...[
                if (lang['skills'] != null)
                  Padding(padding: const EdgeInsets.only(left: 32), child: Wrap(children: (lang['skills'] as List).map((s) => SizedBox(width: 120, child: CheckboxListTile(
                    title: Text(s),
                    value: (_formData[langId]['skills'] as List).contains(s),
                    onChanged: (v) => setState(() {
                      if (v!) (_formData[langId]['skills'] as List).add(s);
                      else (_formData[langId]['skills'] as List).remove(s);
                    }),
                  ))).toList())),
                if (lang['has_specify'] == true)
                  Padding(padding: const EdgeInsets.only(left: 32), child: _buildField({'id': '${langId}_specify', 'label': 'Specify', 'type': 'text'})),
              ]
            ]);
          })
        ]);

      case 'date':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: InkWell(
            onTap: () async {
              final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime(2100));
              if (picked != null) updateValue(picked.toIso8601String().split('T')[0]);
            },
            child: InputDecorator(
              decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), suffixIcon: const Icon(Icons.calendar_today)),
              child: Text((field['onChanged'] != null ? field['initialValue'] : _formData[id]) ?? 'Select Date'),
            ),
          ),
        );

      case 'table':
        final isExpenditure = id == 'expenditure_table';
        return Column(children: [
          _buildTableField(field),
          if (isExpenditure) _buildExpenditureSummary(field),
        ]);

      case 'hierarchical_checkbox':
        final categories = field['categories'] as List;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          ...categories.map((cat) {
            final catId = cat['id'];
            final subPrograms = cat['sub_programs'] as List;
            _formData[catId] ??= [];
            final List selectedSubs = _formData[catId];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                title: Text(cat['label']),
                subtitle: Text('${selectedSubs.length} selected', style: const TextStyle(fontSize: 12)),
                children: subPrograms.map((prog) => CheckboxListTile(
                  title: Text(prog),
                  value: selectedSubs.contains(prog),
                  onChanged: (v) => setState(() {
                    if (v!) selectedSubs.add(prog);
                    else selectedSubs.remove(prog);
                  }),
                )).toList(),
              ),
            );
          }),
        ]);

      case 'income_calculator':
        final List members = _formData['family_members'] ?? [];
        double total = 0;
        for (var m in members) {
          final incomeStr = m['income']?.toString() ?? '0';
          total += double.tryParse(incomeStr) ?? 0;
        }
        return Container(
          width: double.infinity, padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.primary.withOpacity(0.2))),
          child: Column(children: [
            const Text('TOTAL CALCULATED FAMILY INCOME', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 8),
            Text('₹${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ]),
        );

      case 'family_health_tracker':
        final List members = _formData['family_members'] ?? [];
        _formData[id] ??= [];
        final List records = _formData[id];
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary))),
          if (members.isEmpty) const Text('Please add family members in Section 3 first.', style: TextStyle(color: Colors.red, fontSize: 12)),
          ...records.asMap().entries.map((entry) {
            final idx = entry.key;
            final record = Map<String, dynamic>.from(entry.value);
            records[idx] = record;
            record['ncd'] ??= [];
            record['communicable'] ??= [];
            record['others'] ??= [];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                title: Text(record['member_name'] ?? 'Select Member'),
                subtitle: Text('Conditions: ${(record['ncd'] as List).length + (record['communicable'] as List).length + (record['others'] as List).length}'),
                children: [
                  Padding(padding: const EdgeInsets.all(16), child: Column(children: [
                    _radioGroup('Select Family Member', members.map((m) => m['name']?.toString() ?? 'Unnamed').toList(), record['member_name'] ?? '', (v) => setState(() => record['member_name'] = v)),
                    const Divider(),
                    _buildDiseaseCategory('Non-Communicable Diseases', field['ncd_options'], record['ncd']),
                    _buildDiseaseCategory('Communicable Diseases', field['communicable_options'], record['communicable']),
                    _buildDiseaseCategory('Other Illnesses', field['other_categories'], record['others']),
                  ]))
                ],
              ),
            );
          }),
          ElevatedButton.icon(onPressed: () => setState(() => records.add({})), icon: const Icon(Icons.add_moderator), label: const Text('Add Health Record')),
        ]);

      case 'group':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label.isNotEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
            ...(field['fields'] as List).map((f) => _buildField(f)),
          ],
        );

      case 'multi_text':
        final count = field['count'] ?? 1;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
            for (int i = 1; i <= count; i++)
              _buildField({'id': '${id}_$i', 'label': '$i. details', 'type': 'text'}),
          ],
        );

      case 'signature':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildField({'id': '${id}_name', 'label': label, 'type': 'text'}),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Signature: __________________________', style: TextStyle(fontSize: 16))),
        ]);

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTableField(Map<String, dynamic> field) {
    final id = field['id'];
    final label = field['label'];
    if (_formData[id] == null) {
      if (field['rows'] != null) {
        _formData[id] = List.from(field['rows']);
      } else {
        _formData[id] = [];
      }
    }
    final List rows = _formData[id];
    final columns = (field['columns'] ?? field['table_columns']) as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 12.0), child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary))),
        ...rows.asMap().entries.map((entry) {
          final index = entry.key;
          final Map<String, dynamic> rowData = Map<String, dynamic>.from(entry.value);
          rows[index] = rowData;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              title: Text('${field['record_name'] ?? (id.contains('family') ? 'Member' : 'Record')} ${index + 1}'),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Column(
                    children: columns.map((col) {
                      final colId = col['id'];
                      final colType = col['type'];
                      if (colType == 'auto_increment') return Text('No: ${index + 1}');
                      if (colType == 'static') return Text('${col['label']}: ${rowData[colId] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold));
                      return _buildField({
                        ...col,
                        'id': '${id}_${index}_$colId',
                        'label': col['label'],
                        'initialValue': rowData[colId],
                        'onChanged': (val) => setState(() => rowData[colId] = val),
                      });
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        }),
        if (field['allow_add_rows'] != false)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton.icon(
              onPressed: () => setState(() => rows.add({})),
              icon: const Icon(Icons.add),
              label: Text('Add ${field['record_name'] ?? 'Record'}'),
            ),
          ),
      ],
    );
  }

  Widget _buildDiseaseCategory(String title, List options, List selectedList) {
    return Card(
      color: Colors.grey.shade50,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        children: options.map((opt) => CheckboxListTile(
          title: Text(opt, style: const TextStyle(fontSize: 12)),
          value: selectedList.contains(opt),
          dense: true,
          onChanged: (v) {
            setState(() {
              if (v!) selectedList.add(opt);
              else selectedList.remove(opt);
            });
          },
        )).toList(),
      ),
    );
  }

  Widget _buildExpenditureSummary(Map<String, dynamic> field) {
    final List records = _formData[field['id']] ?? [];
    double totalAmount = 0;
    double totalPercent = 0;
    for (var record in records) {
      final r = Map<String, dynamic>.from(record);
      totalAmount += double.tryParse(r['amount_spent']?.toString() ?? '0') ?? 0;
      totalPercent += double.tryParse(r['percentage']?.toString() ?? '0') ?? 0;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 24, top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Text('TOTAL EXPENDITURE SUMMARY', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text('Total Amount', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text('₹${totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
              ),
              Container(width: 1, height: 30, color: AppColors.primary.withOpacity(0.2)),
              Expanded(
                child: Column(
                  children: [
                    const Text('Total Percentage', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text('${totalPercent.toStringAsFixed(1)}%', 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: totalPercent > 100 ? Colors.red : Colors.green),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
