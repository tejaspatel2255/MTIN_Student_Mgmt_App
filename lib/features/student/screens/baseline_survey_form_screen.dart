import 'dart:convert';
import 'package:flutter/material.dart';
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
  bool _isSaving = false;

  // --- SECTION 1 STATE ---
  String _facilityType = '';
  String _communityArea = '';
  String _areaType = '';
  final _areaNameCtrl = TextEditingController();
  final _healthCentreTypeCtrl = TextEditingController(); 
  String _healthCentreType = '';
  final _headNameCtrl = TextEditingController();
  String _familyType = '';
  String _religion = '';
  final _subCasteCtrl = TextEditingController();

  // --- SECTION 2 STATE ---
  String _houseType = '';
  final _numRoomsCtrl = TextEditingController();
  String _roomsAdequacy = '';
  String _occupancy = '';
  final _monthlyRentCtrl = TextEditingController();
  String _ventilation = '';
  String _lighting = '';
  String _waterSupply = '';
  final _waterSpecifyCtrl = TextEditingController();
  String _kitchen = '';
  String _drainage = '';
  String _lavatory = '';

  // --- SECTION 3 STATE ---
  List<Map<String, dynamic>> _familyMembers = [];
  Map<String, dynamic> _emptyMember() => {
    'name': TextEditingController(),
    'relationship': null, 
    'age': TextEditingController(),
    'gender': null, 
    'education': null, 
    'occupation': null, 
    'income': TextEditingController(),
    'health_status': null, 
  };
  String _totalIncomeClass = '';
  String _socioEconomicClass = '';

  // --- SECTION 4 STATE ---
  Map<String, bool> _transport = {
    'Tractor / Tempo': false,
    'Own Vehicle': false,
    'Uses GTS / GSRTC': false,
    'Private Bus': false,
    'Train': false,
  };
  Map<String, bool> _communication = {
    'Telephone / Mobile': false,
    'Television': false,
    'Radio': false,
    'Newspaper / Magazine': false,
    'Post and Telegraph / Email': false,
  };
  String _motherTongue = '';
  final _motherTongueOtherCtrl = TextEditingController();
  Map<String, dynamic> _languages = {
    'Gujarati': {'selected': false, 'read': false, 'write': false},
    'Hindi': {'selected': false, 'read': false, 'write': false},
    'English': {'selected': false, 'read': false, 'write': false},
    'Others': {'selected': false, 'specify': TextEditingController()},
  };

  // --- SECTION 5 STATE ---
  final List<String> _foodItems = ["Rice", "Bajra", "Jowar", "Wheat", "Vegetables", "Fish", "Meat", "Egg", "Milk & Milk Products", "Pulses", "Tubers"];
  List<Map<String, String?>> _diet = List.generate(11, (_) => {'used': null, 'traditional': null, 'ideal': null, 'unhygienic': null});

  // --- SECTION 6 STATE ---
  final List<String> _expItems = ["Food", "Clothing", "Housing", "Medicine", "Children Education", "Recreation (movie etc)", "Smoking, Alcohol", "Debt", "Savings", "Other (specify)"];
  List<Map<String, dynamic>> _expenditure = List.generate(10, (_) => {'amount': TextEditingController(), 'percent': TextEditingController()});

  // --- SECTION 7 STATE ---
  List<Map<String, dynamic>> _healthRecords = [];
  Map<String, dynamic> _emptyHealthRecord() => {
    'memberName': null,
    'ncd': <String>[],
    'communicable': <String>[],
    'others': <String>[],
    'other_specify': TextEditingController(),
  };

  // --- SECTION 8 STATE ---
  final _healthKnowledgeCtrl = TextEditingController();
  final _nutritionKnowledgeCtrl = TextEditingController();
  Map<String, bool> _utilization = {
    'Private Hospital': false,
    'Govt Hospital': false,
    'CHC': false,
    'PHC': false,
    'Local Doctors': false,
    'Other Systems': false,
  };
  final _communityLeadersCtrl = TextEditingController();

  // --- SECTION 9 STATE ---
  String _hasPregnant = '';
  List<Map<String, dynamic>> _pregnantWomen = [];
  Map<String, dynamic> _emptyPregnant() => {
    'name': TextEditingController(),
    'gravida': TextEditingController(),
    'registered': null,
    'ifa': null,
    'tt': null,
  };

  // --- SECTION 10 STATE ---
  List<Map<String, dynamic>> _births = [];
  List<Map<String, dynamic>> _deaths = [];
  List<Map<String, dynamic>> _marriages = [];
  Map<String, dynamic> _emptyVital(String type) => {
    'date': TextEditingController(), 
    'gender': null,
    'parents_or_name': TextEditingController(),
    'remarks': TextEditingController(),
  };

  // --- SECTION 11 STATE ---
  List<Map<String, dynamic>> _immunization = [];
  Map<String, dynamic> _emptyImm() => {
    'name': TextEditingController(),
    'dob': TextEditingController(),
    'bcg': null, 'opv0': null, 'opv1': null, 'opv2': null, 'opvB1': null, 'opvB2': null,
    'penta1': null, 'penta2': null, 'penta3': null, 'pentaB1': null, 'pentaB2': null,
    'mr': null,
  };
  final _immRemarksCtrl = TextEditingController();

  // --- SECTION 12 STATE ---
  String _hasEligibleCouples = '';
  List<Map<String, dynamic>> _eligibleCouples = [];
  Map<String, dynamic> _emptyCouple() => {
    'name': TextEditingController(),
    'age': TextEditingController(),
    'gender': null,
    'priority1': TextEditingController(),
    'priority2': TextEditingController(),
  };
  final _eligibleRemarksCtrl = TextEditingController();
  final _contraceptiveMethodCtrl = TextEditingController();
  Map<String, bool> _fpIntention = {'Vasectomy': false, 'Tubal Ligation': false};
  final _fpReasonCtrl = TextEditingController();

  // --- SECTION 13 STATE ---
  List<Map<String, dynamic>> _malnutrition = [];
  Map<String, dynamic> _emptyMal() => {
    'name': TextEditingController(),
    'age': TextEditingController(),
    'kwashiorkor': null, 'marasmus': null, 'vitA': null, 'anemia': null, 'rickets': null,
  };
  final _malRemarksCtrl = TextEditingController();

  // --- SECTION 14 STATE ---
  String _sewageHygienic = ''; final _sewageReasonCtrl = TextEditingController();
  String _wasteHygienic = ''; final _wasteReasonCtrl = TextEditingController();
  Map<String, bool> _wasteMethods = {'Composting': false, 'Burning': false, 'Burying': false, 'Dumping': false};
  String _excretaHygienic = ''; final _excretaReasonCtrl = TextEditingController();
  String _cattleHygienic = ''; String _cattleLocation = ''; final _cattleReasonCtrl = TextEditingController();
  String _hasWell = ''; final _wellMaintainedCtrl = TextEditingController(); final _wellChlorinationCtrl = TextEditingController(); final _wellNoChlorineReasonCtrl = TextEditingController();
  String _houseClean = ''; final _houseCleanReasonCtrl = TextEditingController();
  final _houseSprayDateCtrl = TextEditingController(); final _houseSprayReasonCtrl = TextEditingController();
  String _hasBreeding = ''; final _breedingSpecifyCtrl = TextEditingController();
  String _hasStrayDogs = ''; final _dogCountCtrl = TextEditingController();

  // --- SECTION 15 STATE ---
  Map<String, bool> _treatmentPlace = {'Hospital / CHC': false, 'PHC / Sub Centre': false, 'Private Nursing Home': false, 'Indigenous / Vaidya': false};
  String _agencyAdequate = ''; final _agencyReasonCtrl = TextEditingController();
  String _hasInsurance = ''; final _insuranceSpecifyCtrl = TextEditingController();
  final _techoNumberCtrl = TextEditingController();

  // --- SECTION 16 STATE ---
  List<TextEditingController> _strengths = [TextEditingController()];
  List<TextEditingController> _weaknesses = [TextEditingController()];
  Map<String, List<String>> _nationalProgs = {}; 
  final _drugPurchasePlaceCtrl = TextEditingController();
  String _medicineCompliance = '';
  final _contactNumberCtrl = TextEditingController();

  // --- SECTION 17 STATE ---
  List<TextEditingController> _problems = [TextEditingController()];
  final _surveyDateCtrl = TextEditingController();
  final _studentNameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _familyMembers = [_emptyMember()];
    if (widget.survey != null) _loadExistingData();
  }

  void _loadExistingData() {
    final data = widget.survey!.data;
    setState(() {
      _facilityType = data['facility_type'] ?? '';
      _communityArea = data['community_area'] ?? '';
      _areaType = data['area_type'] ?? '';
      _areaNameCtrl.text = data['area_name'] ?? '';
      _healthCentreType = data['health_centre_type'] ?? '';
      _headNameCtrl.text = data['head_of_family_name'] ?? '';
      _familyType = data['family_type'] ?? '';
      _religion = data['religion'] ?? '';
      _subCasteCtrl.text = data['sub_caste'] ?? '';
      
      _houseType = data['house_type'] ?? '';
      _numRoomsCtrl.text = data['num_rooms'] ?? '';
      _roomsAdequacy = data['rooms_adequacy'] ?? '';
      _occupancy = data['occupancy'] ?? '';
      _monthlyRentCtrl.text = data['monthly_rent'] ?? '';
      _ventilation = data['ventilation'] ?? '';
      _lighting = data['lighting'] ?? '';
      _waterSupply = data['water_supply'] ?? '';
      _waterSpecifyCtrl.text = data['water_specify'] ?? '';
      _kitchen = data['kitchen'] ?? '';
      _drainage = data['drainage'] ?? '';
      _lavatory = data['lavatory'] ?? '';

      if (data['family_members'] != null) {
        _familyMembers = (data['family_members'] as List).map((m) => {
          'name': TextEditingController(text: m['name']),
          'relationship': m['relationship'],
          'age': TextEditingController(text: m['age']),
          'gender': m['gender'],
          'education': m['education'],
          'occupation': m['occupation'],
          'income': TextEditingController(text: m['income']),
          'health_status': m['health_status'],
        }).toList();
      }
      
      _totalIncomeClass = data['total_income_class'] ?? '';
      _socioEconomicClass = data['socio_economic_class'] ?? '';
      
      if (data['transport'] != null) _transport = Map<String, bool>.from(data['transport']);
      if (data['communication'] != null) _communication = Map<String, bool>.from(data['communication']);
      _motherTongue = data['mother_tongue'] ?? '';
      _motherTongueOtherCtrl.text = data['mother_tongue_other'] ?? '';

      if (data['health_records'] != null) {
        _healthRecords = (data['health_records'] as List).map((r) => {
          'memberName': r['memberName'],
          'ncd': List<String>.from(r['ncd'] ?? []),
          'communicable': List<String>.from(r['communicable'] ?? []),
          'others': List<String>.from(r['others'] ?? []),
          'other_specify': TextEditingController(text: r['other_specify']),
        }).toList();
      }

      _healthKnowledgeCtrl.text = data['health_knowledge'] ?? '';
      _nutritionKnowledgeCtrl.text = data['nutrition_knowledge'] ?? '';
      _contactNumberCtrl.text = data['contact_number'] ?? '';
      _surveyDateCtrl.text = data['survey_date'] ?? '';
      _studentNameCtrl.text = data['student_name'] ?? '';
    });
  }

  // --- UI HELPERS ---
  Widget _sectionCard(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
          child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        ),
        Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children)),
      ]),
    );
  }

  Widget _label(String text) => Padding(padding: const EdgeInsets.only(top: 12, bottom: 6), child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)));

  Widget _textInput(String label, TextEditingController ctrl, {TextInputType? keyboard, int lines = 1}) =>
    Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: TextFormField(
      controller: ctrl, keyboardType: keyboard, maxLines: lines,
      decoration: InputDecoration(labelText: label, isDense: true),
    ));

  Widget _dropdown(String label, List<String> options, String? value, ValueChanged<String?> onChanged) =>
    Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: DropdownButtonFormField<String>(
      value: value, isExpanded: true, decoration: InputDecoration(labelText: label, isDense: true),
      hint: const Text('Select...'),
      items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis))).toList(),
      onChanged: onChanged,
    ));

  Widget _radioGroup(String label, List<String> options, String groupValue, ValueChanged<String> onChanged) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label(label),
      ...options.map((opt) => RadioListTile<String>(
        title: Text(opt, style: const TextStyle(fontSize: 13)), value: opt, groupValue: groupValue,
        dense: true, contentPadding: EdgeInsets.zero, onChanged: (v) => onChanged(v!),
      )),
    ]);

  Widget _yesNo(String label, String groupValue, ValueChanged<String> onChanged) =>
    Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [
      Expanded(child: _label(label)),
      Radio<String>(value: 'Yes', groupValue: groupValue, onChanged: (v) => onChanged(v!)), const Text('Yes', style: TextStyle(fontSize: 13)),
      const SizedBox(width: 12),
      Radio<String>(value: 'No', groupValue: groupValue, onChanged: (v) => onChanged(v!)), const Text('No', style: TextStyle(fontSize: 13)),
    ]));

  Widget _checkboxGroup(String label, Map<String, bool> map, Function(String, bool) onChanged) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label(label),
      ...map.keys.map((k) => CheckboxListTile(
        title: Text(k, style: const TextStyle(fontSize: 13)), value: map[k]!,
        dense: true, contentPadding: EdgeInsets.zero, onChanged: (v) => onChanged(k, v!),
      )),
    ]);

  Widget _dateInput(String label, TextEditingController ctrl) =>
    Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: TextFormField(
      controller: ctrl, readOnly: true, decoration: InputDecoration(labelText: label, suffixIcon: const Icon(Icons.calendar_today), isDense: true),
      onTap: () async {
        final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime(2100));
        if (d != null) setState(() => ctrl.text = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}');
      },
    ));

  // --- SECTIONS ---
  Widget _section1() => _sectionCard("SECTION 1: Basic Information", [
    _dropdown("Facility Type", ["PHCs", "CHCs", "UHCs"], _facilityType.isEmpty ? null : _facilityType, (v) => setState(() { _facilityType = v!; _communityArea = ''; })),
    if (_facilityType == "PHCs") _radioGroup("Community Area (PHC)", ["Changa", "Piplav", "Bandhani", "Morad", "Sihol", "Nar"], _communityArea, (v) => setState(() => _communityArea = v)),
    if (_facilityType == "CHCs") _radioGroup("Community Area (CHC)", ["Sarsa", "Tarapur", "Mahelav"], _communityArea, (v) => setState(() => _communityArea = v)),
    if (_facilityType == "UHCs") _radioGroup("Community Area (UHC)", ["Nehrubaugh", "PP Unit Anand", "Bakrol", "Ajarpura", "Navli"], _communityArea, (v) => setState(() => _communityArea = v)),
    _radioGroup("Name of the area", ["Rural", "Urban"], _areaType, (v) => setState(() => _areaType = v)),
    if (_areaType.isNotEmpty) _textInput("Specify area name", _areaNameCtrl),
    _radioGroup("Name of the Health Centre (Type)", ["SC", "HWCs", "PHC", "CHC", "UHC"], _healthCentreType, (v) => setState(() => _healthCentreType = v)),
    _textInput("Name of the Head of the family", _headNameCtrl),
    _radioGroup("Type of family", ["Nuclear", "Joint", "Single"], _familyType, (v) => setState(() => _familyType = v)),
    _radioGroup("Religion", ["Hindu", "Muslim", "Christian", "Any Other"], _religion, (v) => setState(() => _religion = v)),
    if (_religion == "Any Other") _textInput("Specify the sub caste", _subCasteCtrl),
  ]);

  Widget _section2() => _sectionCard("SECTION 2: Housing Condition", [
    _radioGroup("6.1 Type of house", ["Pucca", "Semi Pucca", "Kutcha"], _houseType, (v) => setState(() => _houseType = v)),
    _textInput("6.2 Number of rooms", _numRoomsCtrl, keyboard: TextInputType.number),
    _radioGroup("6.2 Adequacy", ["Adequate", "Inadequate"], _roomsAdequacy, (v) => setState(() => _roomsAdequacy = v)),
    _radioGroup("6.3 Occupancy", ["Tenant", "Owner"], _occupancy, (v) => setState(() => _occupancy = v)),
    if (_occupancy == "Tenant") _textInput("Monthly Rent", _monthlyRentCtrl, keyboard: TextInputType.number),
    _radioGroup("6.4 Ventilation", ["Adequate", "Inadequate", "No Ventilation"], _ventilation, (v) => setState(() => _ventilation = v)),
    _radioGroup("6.5 Lighting", ["Electricity", "Gas lamp", "Oil lamp"], _lighting, (v) => setState(() => _lighting = v)),
    _radioGroup("6.6 Water Supply", ["Tap / Hand pump", "Well", "Open Tank", "Others"], _waterSupply, (v) => setState(() => _waterSupply = v)),
    if (_waterSupply == "Others") _textInput("Specify others", _waterSpecifyCtrl),
    _radioGroup("6.7 Kitchen", ["Separate", "Corner of the room", "Veranda"], _kitchen, (v) => setState(() => _kitchen = v)),
    _radioGroup("6.8 Drainage", ["Adequate", "Inadequate", "No Drainage"], _drainage, (v) => setState(() => _drainage = v)),
    _radioGroup("6.9 Lavatory", ["Own Latrine", "Public Latrine", "Open air defecation"], _lavatory, (v) => setState(() => _lavatory = v)),
  ]);

  Widget _section3() {
    double totalIncome = 0;
    for (var m in _familyMembers) { totalIncome += double.tryParse(m['income'].text) ?? 0; }
    return _sectionCard("SECTION 3: Family Composition", [
      ..._familyMembers.asMap().entries.map((entry) {
        int i = entry.key; var m = entry.value;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            title: Text('${m['name'].text.isEmpty ? "Member ${i + 1}" : m['name'].text}'),
            children: [
              Padding(padding: const EdgeInsets.all(12), child: Column(children: [
                _textInput("Name", m['name']),
                _dropdown("Relationship with Head", ["Hof", "Father", "Mother", "Husband", "Wife", "Brother", "Sister", "Uncle", "Aunty", "Son", "Daughter", "Grand Son", "Grand Daughter", "Daughter-in-law", "Other"], m['relationship'], (v) => setState(() => m['relationship'] = v)),
                _textInput("Age", m['age'], keyboard: TextInputType.number),
                _radioGroup("Gender", ["Male", "Female", "Other"], m['gender'] ?? '', (v) => setState(() => m['gender'] = v)),
                _dropdown("Education", ["Professional Degree, Post Graduate", "Graduate", "Diploma", "High secondary school", "Secondary school", "Primary school or literate", "Illiterate"], m['education'], (v) => setState(() => m['education'] = v)),
                _dropdown("Occupation", ["Laborer", "Farmer", "Own Business", "Private job", "Government job", "Unemployment", "Student", "Housewife", "Retired"], m['occupation'], (v) => setState(() => m['occupation'] = v)),
                _textInput("Income", m['income'], keyboard: TextInputType.number),
                _dropdown("General Health Status", ["Healthy", "Unhealthy"], m['health_status'], (v) => setState(() => m['health_status'] = v)),
                TextButton.icon(onPressed: () => setState(() => _familyMembers.removeAt(i)), icon: const Icon(Icons.delete, color: Colors.red), label: const Text("Remove Member", style: TextStyle(color: Colors.red))),
              ])),
            ],
          ),
        );
      }),
      ElevatedButton.icon(onPressed: () => setState(() => _familyMembers.add(_emptyMember())), icon: const Icon(Icons.add), label: const Text("Add Family Member")),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("TOTAL FAMILY INCOME:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text("₹${totalIncome.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
        ]),
      ),
      _dropdown("7A. Total Income Class", ["Below Rs. 1000", "Rs. 1000–1500", "Rs. 1501–2000", "Rs. 2001–2500", "Rs. 2501 and above"], _totalIncomeClass.isEmpty ? null : _totalIncomeClass, (v) => setState(() => _totalIncomeClass = v!)),
      _dropdown("7B. Socio-Economic Class", ["Class I", "Class II", "Class III", "Class IV", "Class V"], _socioEconomicClass.isEmpty ? null : _socioEconomicClass, (v) => setState(() => _socioEconomicClass = v!)),
    ]);
  }

  Widget _section4() => _sectionCard("SECTION 4: Transport & Communication", [
    _checkboxGroup("8. Transport", _transport, (k, v) => setState(() => _transport[k] = v)),
    _checkboxGroup("8.1 Communication", _communication, (k, v) => setState(() => _communication[k] = v)),
    _radioGroup("8.2 Mother Tongue", ["Gujarati", "Hindi", "Others"], _motherTongue, (v) => setState(() => _motherTongue = v)),
    if (_motherTongue == "Others") _textInput("Specify", _motherTongueOtherCtrl),
    _label("8.3 Language Skills"),
    ..._languages.keys.map((lang) {
      var l = _languages[lang];
      return Column(children: [
        CheckboxListTile(title: Text(lang, style: const TextStyle(fontSize: 13)), value: l['selected'], dense: true, contentPadding: EdgeInsets.zero, onChanged: (v) => setState(() => l['selected'] = v!)),
        if (l['selected'] == true) Padding(padding: const EdgeInsets.only(left: 32), child: Column(children: [
          if (lang != 'Others') ...[
            CheckboxListTile(title: const Text("Read", style: TextStyle(fontSize: 12)), value: l['read'], dense: true, contentPadding: EdgeInsets.zero, onChanged: (v) => setState(() => l['read'] = v!)),
            CheckboxListTile(title: const Text("Write", style: TextStyle(fontSize: 12)), value: l['write'], dense: true, contentPadding: EdgeInsets.zero, onChanged: (v) => setState(() => l['write'] = v!)),
          ] else _textInput("Specify Language", l['specify']),
        ])),
      ]);
    }),
  ]);

  Widget _section5() => _sectionCard("SECTION 5: Dietary Pattern", [
    ..._foodItems.asMap().entries.map((entry) {
      int i = entry.key; String name = entry.value; var d = _diet[i];
      return Card(
        margin: const EdgeInsets.only(bottom: 4),
        child: ExpansionTile(
          title: Text("${i + 1}. $name", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          children: [
            Padding(padding: const EdgeInsets.all(12), child: Column(children: [
              _yesNo("Food Used", d['used'] ?? '', (v) => setState(() => d['used'] = v)),
              _yesNo("Preparation - Traditional", d['traditional'] ?? '', (v) => setState(() => d['traditional'] = v)),
              _yesNo("Preparation - Ideal", d['ideal'] ?? '', (v) => setState(() => d['ideal'] = v)),
              _yesNo("Preparation - Unhygienic", d['unhygienic'] ?? '', (v) => setState(() => d['unhygienic'] = v)),
            ])),
          ],
        ),
      );
    }),
  ]);

  Widget _section6() {
    double totalExp = 0;
    for (var e in _expenditure) { totalExp += double.tryParse(e['amount'].text) ?? 0; }
    return _sectionCard("SECTION 6: Statement of Expenditure", [
      ..._expItems.asMap().entries.map((entry) {
        int i = entry.key; String name = entry.value; var e = _expenditure[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 4),
          child: ExpansionTile(
            title: Text("${i + 1}. $name", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            children: [
              Padding(padding: const EdgeInsets.all(12), child: Column(children: [
                _textInput("Amount Spent", e['amount'], keyboard: TextInputType.number),
                _textInput("% of Total", e['percent'], keyboard: TextInputType.number),
              ])),
            ],
          ),
        );
      }),
      const SizedBox(height: 12),
      Text("Total Amount Spent: ₹${totalExp.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
    ]);
  }

  Widget _section7() => _sectionCard("SECTION 7: Health Tracker", [
    ..._healthRecords.asMap().entries.map((entry) {
      int i = entry.key; var r = entry.value;
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ExpansionTile(
          title: Text(r['memberName'] ?? "Health Record ${i + 1}"),
          children: [
            Padding(padding: const EdgeInsets.all(12), child: Column(children: [
              _dropdown("Select Member", _familyMembers.map<String>((m) => m['name'].text.isEmpty ? "Unnamed" : m['name'].text as String).toList(), r['memberName'], (v) => setState(() => r['memberName'] = v)),
              _buildDiseaseList("Non-Communicable", ["Diabetes", "Hypertension", "Cancer", "Stroke", "Heart Disease", "Blindness", "Obesity", "Epilepsy"], r['ncd']),
              _buildDiseaseList("Communicable", ["Tuberculosis", "Dengue", "Malaria", "COVID-19", "Hepatitis", "Typhoid", "Cholera", "HIV/AIDS"], r['communicable']),
              _buildDiseaseList("Others", ["Fever", "Skin Disease", "Cough", "Other Illness"], r['others'], otherController: r['other_specify']),
              TextButton.icon(onPressed: () => setState(() => _healthRecords.removeAt(i)), icon: const Icon(Icons.delete, color: Colors.red), label: const Text("Delete Record", style: TextStyle(color: Colors.red))),
            ])),
          ],
        ),
      );
    }),
    ElevatedButton.icon(onPressed: () => setState(() => _healthRecords.add(_emptyHealthRecord())), icon: const Icon(Icons.add_moderator), label: const Text("Add Disease Tracker Record")),
  ]);

  Widget _buildDiseaseList(String title, List<String> options, List<String> selected, {TextEditingController? otherController}) {
    return Card(
      color: Colors.grey.shade50, margin: const EdgeInsets.only(top: 8),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        children: [
          ...options.map((opt) => CheckboxListTile(
            title: Text(opt, style: const TextStyle(fontSize: 12)), value: selected.contains(opt),
            dense: true, onChanged: (v) => setState(() { if (v!) selected.add(opt); else selected.remove(opt); }),
          )),
          if (otherController != null && selected.contains("Other Illness"))
            Padding(padding: const EdgeInsets.all(12), child: _textInput("Specify Other Illness", otherController, lines: 2)),
        ],
      ),
    );
  }

  Widget _section8() => _sectionCard("SECTION 8: Health Attitude", [
    _textInput("a. Knowledge about health", _healthKnowledgeCtrl, lines: 3),
    _textInput("b. Knowledge about nutrition", _nutritionKnowledgeCtrl, lines: 3),
    _checkboxGroup("c. Utilization of health services", _utilization, (k, v) => setState(() => _utilization[k] = v)),
    _textInput("d. Community leaders", _communityLeadersCtrl),
  ]);

  Widget _section9() => _sectionCard("SECTION 9: Pregnant Women", [
    _yesNo("Is anyone pregnant?", _hasPregnant, (v) => setState(() => _hasPregnant = v)),
    if (_hasPregnant == 'Yes') ...[
      ..._pregnantWomen.asMap().entries.map((entry) {
        int i = entry.key; var p = entry.value;
        return Card(child: ExpansionTile(title: Text("Woman ${i + 1}"), children: [
          Padding(padding: const EdgeInsets.all(12), child: Column(children: [
            _textInput("Name", p['name']), _textInput("Gravida", p['gravida']),
            _yesNo("Registered?", p['registered'] ?? '', (v) => setState(() => p['registered'] = v)),
            _yesNo("IFA Tablets?", p['ifa'] ?? '', (v) => setState(() => p['ifa'] = v)),
            _yesNo("Tetanus Toxoid?", p['tt'] ?? '', (v) => setState(() => p['tt'] = v)),
          ]))
        ]));
      }),
      ElevatedButton(onPressed: () => setState(() => _pregnantWomen.add(_emptyPregnant())), child: const Text("Add Record")),
    ]
  ]);

  Widget _section10() => _sectionCard("SECTION 10: Vital Statistics", [
    _label("17.1 Births"), _buildVitalList(_births, "Birth", "Parents"),
    _label("17.2 Deaths"), _buildVitalList(_deaths, "Death", "Name"),
    _label("17.3 Marriages"), _buildVitalList(_marriages, "Marriage", "Name"),
  ]);

  Widget _buildVitalList(List<Map<String, dynamic>> list, String type, String nameLabel) {
    return Column(children: [
      ...list.asMap().entries.map((entry) {
        int i = entry.key; var v = entry.value;
        return Card(child: ExpansionTile(title: Text("$type ${i+1}"), children: [
          Padding(padding: const EdgeInsets.all(12), child: Column(children: [
            _dateInput("Date", v['date']),
            _radioGroup("Gender", ["Male", "Female"], v['gender'] ?? '', (val) => setState(() => v['gender'] = val)),
            _textInput(nameLabel, v['parents_or_name']),
            _textInput("Remarks", v['remarks']),
          ]))
        ]));
      }),
      ElevatedButton(onPressed: () => setState(() => list.add(_emptyVital(type))), child: Text("Add $type")),
    ]);
  }

  Widget _section11() => _sectionCard("SECTION 11: Immunization", [
    ..._immunization.asMap().entries.map((entry) {
      int i = entry.key; var m = entry.value;
      return Card(child: ExpansionTile(title: Text("Child ${i+1}"), children: [
        Padding(padding: const EdgeInsets.all(12), child: Column(children: [
          _textInput("Name", m['name']), _dateInput("DOB", m['dob']),
          ...["bcg", "opv0", "opv1", "opv2", "opvB1", "opvB2", "penta1", "penta2", "penta3", "pentaB1", "pentaB2", "mr"].map((vax) => 
            _yesNo(vax.toUpperCase(), m[vax] ?? '', (v) => setState(() => m[vax] = v))
          )
        ]))
      ]));
    }),
    ElevatedButton(onPressed: () => setState(() => _immunization.add(_emptyImm())), child: const Text("Add Child")),
    _textInput("General Remarks", _immRemarksCtrl, lines: 2),
  ]);

  Widget _section12() => _sectionCard("SECTION 12: Eligible Couples", [
    _yesNo("Are there eligible couples?", _hasEligibleCouples, (v) => setState(() => _hasEligibleCouples = v)),
    if (_hasEligibleCouples == 'Yes') ...[
      ..._eligibleCouples.asMap().entries.map((entry) {
        int i = entry.key; var c = entry.value;
        return Card(child: ExpansionTile(title: Text("Couple ${i+1}"), children: [
          Padding(padding: const EdgeInsets.all(12), child: Column(children: [
            _textInput("Name", c['name']), _textInput("Age", c['age'], keyboard: TextInputType.number),
            _radioGroup("Gender", ["Male", "Female"], c['gender'] ?? '', (v) => setState(() => c['gender'] = v)),
            _textInput("I Priority", c['priority1']), _textInput("II Priority", c['priority2']),
          ]))
        ]));
      }),
      ElevatedButton(onPressed: () => setState(() => _eligibleCouples.add(_emptyCouple())), child: const Text("Add Couple")),
    ],
    _textInput("Remarks", _eligibleRemarksCtrl),
    _textInput("19.1 Contraceptive Method", _contraceptiveMethodCtrl),
    _checkboxGroup("19.2 Intention", _fpIntention, (k, v) => setState(() => _fpIntention[k] = v)),
    _textInput("19.3 Reason if not interested", _fpReasonCtrl),
  ]);

  Widget _section13() => _sectionCard("SECTION 13: Malnutrition", [
    ..._malnutrition.asMap().entries.map((entry) {
      int i = entry.key; var m = entry.value;
      return Card(child: ExpansionTile(title: Text("Malnutrition Child ${i+1}"), children: [
        Padding(padding: const EdgeInsets.all(12), child: Column(children: [
          _textInput("Name", m['name']), _textInput("Age", m['age']),
          ...['kwashiorkor', 'marasmus', 'vitA', 'anemia', 'rickets'].map((cond) => _yesNo(cond.capitalize(), m[cond] ?? '', (v) => setState(() => m[cond] = v)))
        ]))
      ]));
    }),
    ElevatedButton(onPressed: () => setState(() => _malnutrition.add(_emptyMal())), child: const Text("Add Child")),
    _textInput("Remarks", _malRemarksCtrl),
  ]);

  Widget _section14() => _sectionCard("SECTION 14: Environmental Sanitation", [
    _yesNo("21. Sewage hygienically disposed?", _sewageHygienic, (v) => setState(() => _sewageHygienic = v)),
    if (_sewageHygienic == 'No') _textInput("Reason", _sewageReasonCtrl),
    _yesNo("22. Waste hygienically disposed?", _wasteHygienic, (v) => setState(() => _wasteHygienic = v)),
    if (_wasteHygienic == 'Yes') _checkboxGroup("Methods", _wasteMethods, (k, v) => setState(() => _wasteMethods[k] = v)),
    if (_wasteHygienic == 'No') _textInput("Reason", _wasteReasonCtrl),
    _yesNo("23. Excreta hygienically disposed?", _excretaHygienic, (v) => setState(() => _excretaHygienic = v)),
    if (_excretaHygienic == 'No') _textInput("Reason", _excretaReasonCtrl),
    _yesNo("24. Cattle housed hygienically?", _cattleHygienic, (v) => setState(() => _cattleHygienic = v)),
    if (_cattleHygienic == 'Yes') _radioGroup("Location", ["Separate", "Within House"], _cattleLocation, (v) => setState(() => _cattleLocation = v)),
    if (_cattleHygienic == 'No') _textInput("Reason", _cattleReasonCtrl),
    _yesNo("25. Is there a well/pump?", _hasWell, (v) => setState(() => _hasWell = v)),
    if (_hasWell == 'Yes') ...[
      _textInput("25.1 Maintained?", _wellMaintainedCtrl),
      _dateInput("25.2 Last Chlorinated", _wellChlorinationCtrl),
      _textInput("Reason if not chlorinated", _wellNoChlorineReasonCtrl),
    ],
    _yesNo("26. House kept clean?", _houseClean, (v) => setState(() => _houseClean = v)),
    if (_houseClean == 'No') _textInput("Reason", _houseCleanReasonCtrl),
    _dateInput("27. Last house spray date", _houseSprayDateCtrl),
    _textInput("Reason for spray/no spray", _houseSprayReasonCtrl),
    _yesNo("28. Breeding places?", _hasBreeding, (v) => setState(() => _hasBreeding = v)),
    if (_hasBreeding == 'Yes') _textInput("Specify", _breedingSpecifyCtrl),
    _yesNo("29. Stray dogs?", _hasStrayDogs, (v) => setState(() => _hasStrayDogs = v)),
    if (_hasStrayDogs == 'Yes') _textInput("Count", _dogCountCtrl, keyboard: TextInputType.number),
  ]);

  Widget _section15() => _sectionCard("SECTION 15: Healthcare Utilization", [
    _checkboxGroup("30. Treatment location", _treatmentPlace, (k, v) => setState(() => _treatmentPlace[k] = v)),
    _yesNo("31. Official agencies adequate?", _agencyAdequate, (v) => setState(() => _agencyAdequate = v)),
    if (_agencyAdequate == 'No') _textInput("Reason", _agencyReasonCtrl),
    _yesNo("32. Health insurance?", _hasInsurance, (v) => setState(() => _hasInsurance = v)),
    if (_hasInsurance == 'Yes') _textInput("Specify", _insuranceSpecifyCtrl),
    _textInput("33. Techo Number", _techoNumberCtrl),
  ]);

  Widget _section16() => _sectionCard("SECTION 16: Strengths & Weaknesses", [
    _label("35. Strengths"), 
    ..._strengths.asMap().entries.map((e) => Row(children: [
      Expanded(child: _textInput("Strength ${e.key + 1}", e.value)),
      IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), onPressed: () => setState(() => _strengths.removeAt(e.key))),
    ])),
    ElevatedButton.icon(onPressed: () => setState(() => _strengths.add(TextEditingController())), icon: const Icon(Icons.add), label: const Text("Add Strength")),
    
    _label("36. Weaknesses"), 
    ..._weaknesses.asMap().entries.map((e) => Row(children: [
      Expanded(child: _textInput("Weakness ${e.key + 1}", e.value)),
      IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), onPressed: () => setState(() => _weaknesses.removeAt(e.key))),
    ])),
    ElevatedButton.icon(onPressed: () => setState(() => _weaknesses.add(TextEditingController())), icon: const Icon(Icons.add), label: const Text("Add Weakness")),
    
    _label("37. National Health Programmes"),
    const Text("Organized by Domain (Tap to expand)", style: TextStyle(fontSize: 12, color: Colors.grey)),
    ..._nationalProgramOptions.keys.map((domain) => Card(
      child: ExpansionTile(
        title: Text(domain),
        children: _nationalProgramOptions[domain]!.map((prog) => CheckboxListTile(
          title: Text(prog), value: _nationalProgs[domain]?.contains(prog) ?? false, dense: true,
          onChanged: (v) => setState(() {
            _nationalProgs[domain] ??= [];
            if (v!) _nationalProgs[domain]!.add(prog); else _nationalProgs[domain]!.remove(prog);
          }),
        )).toList(),
      ),
    )),
    _textInput("38. Drug purchase place", _drugPurchasePlaceCtrl),
    _radioGroup("38.1 Compliance", ["Complete", "Partial / Few doses", "Unfinished"], _medicineCompliance, (v) => setState(() => _medicineCompliance = v)),
    _textInput("39. Contact Number", _contactNumberCtrl, keyboard: TextInputType.phone),
  ]);

  Widget _section17() => _sectionCard("SECTION 17: Identified Problems", [
    _label("List of Problems"), 
    ..._problems.asMap().entries.map((e) => Row(children: [
      Expanded(child: _textInput("Problem ${e.key + 1}", e.value)),
      IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), onPressed: () => setState(() => _problems.removeAt(e.key))),
    ])),
    ElevatedButton.icon(onPressed: () => setState(() => _problems.add(TextEditingController())), icon: const Icon(Icons.add), label: const Text("Add Problem")),
    
    _dateInput("Date of Survey", _surveyDateCtrl),
    _textInput("Name of the Student", _studentNameCtrl),
    const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("Signature: __________________________", style: TextStyle(fontSize: 16))),
  ]);

  Widget _submitButton() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: SizedBox(
      width: double.infinity, height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
        onPressed: _isSaving ? null : () => _saveForm(),
        child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('SUBMIT BASELINE SURVEY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    ),
  );

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields'), backgroundColor: AppColors.error));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final studentId = context.read<AuthProvider>().currentUser?.id;
      final subjectId = context.read<StudentProvider>().selectedSubject?.id;

      if (studentId == null || subjectId == null) throw 'Student or Subject ID missing';

      final formData = {
        'student_id': studentId,
        'subject_id': subjectId,
        'facility_type': _facilityType,
        'community_area': _communityArea,
        'area_type': _areaType,
        'area_name': _areaNameCtrl.text,
        'health_centre_type': _healthCentreType,
        'head_of_family_name': _headNameCtrl.text,
        'family_type': _familyType,
        'religion': _religion,
        'sub_caste': _subCasteCtrl.text,
        'house_type': _houseType,
        'num_rooms': _numRoomsCtrl.text,
        'rooms_adequacy': _roomsAdequacy,
        'occupancy': _occupancy,
        'monthly_rent': _monthlyRentCtrl.text,
        'ventilation': _ventilation,
        'lighting': _lighting,
        'water_supply': _waterSupply,
        'water_specify': _waterSpecifyCtrl.text,
        'kitchen': _kitchen,
        'drainage': _drainage,
        'lavatory': _lavatory,
        'family_members': _familyMembers.map((m) => {
          'name': m['name'].text,
          'relationship': m['relationship'],
          'age': m['age'].text,
          'gender': m['gender'],
          'education': m['education'],
          'occupation': m['occupation'],
          'income': m['income'].text,
          'health_status': m['health_status'],
        }).toList(),
        'total_income_class': _totalIncomeClass,
        'socio_economic_class': _socioEconomicClass,
        'transport': _transport,
        'communication': _communication,
        'mother_tongue': _motherTongue,
        'mother_tongue_other': _motherTongueOtherCtrl.text,
        'health_records': _healthRecords.map((r) => {
          'memberName': r['memberName'],
          'ncd': r['ncd'],
          'communicable': r['communicable'],
          'others': r['others'],
          'other_specify': (r['other_specify'] as TextEditingController).text,
        }).toList(),
        'health_knowledge': _healthKnowledgeCtrl.text,
        'nutrition_knowledge': _nutritionKnowledgeCtrl.text,
        'strengths': _strengths.map((c) => c.text).where((t) => t.isNotEmpty).toList(),
        'weaknesses': _weaknesses.map((c) => c.text).where((t) => t.isNotEmpty).toList(),
        'problems': _problems.map((c) => c.text).where((t) => t.isNotEmpty).toList(),
        'contact_number': _contactNumberCtrl.text,
        'survey_date': _surveyDateCtrl.text,
        'student_name': _studentNameCtrl.text,
      };

      if (widget.survey == null) {
        await SupabaseService().createBaselineSurvey(formData);
      } else {
        await SupabaseService().updateBaselineSurvey(widget.survey!.id, formData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Survey Saved Successfully!'), backgroundColor: AppColors.success));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving survey: $e'), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Baseline Survey Form')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            _headerCard(), const SizedBox(height: 16),
            _section1(), _section2(), _section3(), _section4(), _section5(), _section6(), _section7(),
            _section8(), _section9(), _section10(), _section11(), _section12(), _section13(),
            _section14(), _section15(), _section16(), _section17(),
            _submitButton(),
          ]),
        ),
      ),
    );
  }

  Widget _headerCard() => Card(
    color: AppColors.primary, child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      const Text("Manikaka Topawala Institute of Nursing", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
      const Text("Charusat Campus, Changa", style: TextStyle(color: Colors.white70, fontSize: 12)),
      const Divider(color: Colors.white24),
      const Text("Community Health Nursing - I", style: TextStyle(color: Colors.white, fontSize: 14)),
    ])),
  );

  final Map<String, List<String>> _nationalProgramOptions = {
    "Maternal and Child Health": ["JSY", "JSSK", "PMMVY", "National Immunization Program"],
    "Communicable Disease": ["NVBDCP", "RNTCP/NTEP", "NLEP", "NACP"],
    "Non-Communicable": ["NPCDCS", "Ayushman Bharat - HWC"],
    "Nutrition": ["NIPI", "Poshan Abhiyan"],
    "Water & Sanitation": ["NRHM/NHM", "Swachh Bharat Mission"],
  };
}

extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1)}";
}
