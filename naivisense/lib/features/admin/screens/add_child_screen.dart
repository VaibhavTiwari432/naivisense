import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../shared/models/api/child_requests.dart';
import '../providers/child_management_provider.dart';

class AddChildScreen extends ConsumerStatefulWidget {
  const AddChildScreen({super.key});

  @override
  ConsumerState<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends ConsumerState<AddChildScreen> {
  int _step = 0;
  final _total = 4;

  final _name = TextEditingController();
  final _nickname = TextEditingController();
  final _dob = TextEditingController();
  String _gender = 'Boy';

  final Set<String> _diagnoses = {};
  String _severity = 'Mild';

  final Set<String> _targets = {};

  final _mother = TextEditingController();
  final _father = TextEditingController();
  final _contact = TextEditingController();
  final _city = TextEditingController();

  static const _diagnosisOptions = [
    'Speech Delay',
    'Autism',
    'ADHD',
    'Occupational Delay',
    'Learning Difficulty',
    'Behavioral Issue',
  ];
  static const _targetOptions = [
    'Speech Therapy',
    'OT',
    'Social Skills',
    'Writing Skills',
    'Sensory Regulation',
    'Eye Contact',
    'Communication',
  ];

  @override
  void dispose() {
    for (final c in [_name, _nickname, _dob, _mother, _father, _contact, _city]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 5),
      firstDate: DateTime(now.year - 18),
      lastDate: now,
    );
    if (picked != null) {
      _dob.text = '${picked.day}/${picked.month}/${picked.year}';
    }
  }

  void _next() {
    if (_step < _total - 1) {
      setState(() => _step++);
    } else {
      _save();
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _save() async {
    if (_name.text.isEmpty || _dob.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Complete required fields')));
      return;
    }
    final parts = _dob.text.split('/');
    final dobStr =
        '${int.tryParse(parts[2]) ?? 2018}-${(int.tryParse(parts[1]) ?? 1).toString().padLeft(2, '0')}-${(int.tryParse(parts[0]) ?? 1).toString().padLeft(2, '0')}';

    final request = ChildCreateRequest(
      fullName: _name.text.trim(),
      nickname: _nickname.text.trim().isEmpty ? null : _nickname.text.trim(),
      dob: dobStr,
      gender: _gender,
      diagnoses: _diagnoses.isEmpty ? ['Not Diagnosed'] : _diagnoses.toList(),
      severity: _severity,
      therapyTargets: _targets.toList(),
      motherName: _mother.text.trim(),
      fatherName: _father.text.trim(),
      contactNumber: _contact.text.trim(),
      city: _city.text.trim(),
    );

    final ok = await ref.read(childrenProvider.notifier).create(request);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_name.text.trim()} added')),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save child. Check your connection.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add New Child'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _step == 0 ? () => context.pop() : _back,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Step ${_step + 1} of $_total',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Row(
                children: List.generate(_total, (i) {
                  final active = i <= _step;
                  return Expanded(
                    child: Container(
                      height: 6,
                      margin: EdgeInsets.only(right: i == _total - 1 ? 0 : 6),
                      decoration: BoxDecoration(
                        color: active ? AppColors.primaryBlue : AppColors.borderLight,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildStep(),
                ),
              ),
              AppButton(
                label: _step == _total - 1 ? 'Save Child' : 'Next',
                onPressed: _next,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _basicStep();
      case 1:
        return _diagnosisStep();
      case 2:
        return _targetsStep();
      default:
        return _parentsStep();
    }
  }

  Widget _basicStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Basic Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        const Text('Child Photo',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.camera_alt_outlined, color: AppColors.textSecondary),
                SizedBox(height: 4),
                Text('Upload Photo',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        _field('Full Name', _name, "Enter child's full name"),
        _field('Nickname (Optional)', _nickname, 'e.g. Chintu'),
        _field('Date of Birth', _dob, 'DD / MM / YYYY',
            readOnly: true, onTap: _pickDob, icon: Icons.calendar_today_rounded),
        const Text('Gender',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _genderBtn('Boy', Icons.face_rounded, AppColors.primaryBlue),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _genderBtn('Girl', Icons.favorite_rounded, AppColors.softCoral),
            ),
          ],
        ),
      ],
    );
  }

  Widget _diagnosisStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Diagnosis & Needs',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const Text('Select all that apply',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _diagnosisOptions
              .map((d) => StatusChip(
                    label: d,
                    color: AppColors.softCoral,
                    selected: _diagnoses.contains(d),
                    onTap: () => setState(() {
                      _diagnoses.contains(d) ? _diagnoses.remove(d) : _diagnoses.add(d);
                    }),
                  ))
              .toList(),
        ),
        const SizedBox(height: 20),
        const Text('Severity', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ['Mild', 'Moderate', 'High Support']
              .map((s) => StatusChip(
                    label: s,
                    color: AppColors.primaryBlue,
                    selected: _severity == s,
                    onTap: () => setState(() => _severity = s),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _targetsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Therapy Targets',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const Text('What should we focus on?',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _targetOptions
              .map((t) => StatusChip(
                    label: t,
                    color: AppColors.mintGreen,
                    selected: _targets.contains(t),
                    onTap: () => setState(() {
                      _targets.contains(t) ? _targets.remove(t) : _targets.add(t);
                    }),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _parentsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Parent & Contact',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        _field('Mother Name', _mother, 'Enter mother name'),
        _field('Father Name', _father, 'Enter father name'),
        _field('Contact Number', _contact, '+91 98765 43210',
            keyboardType: TextInputType.phone),
        _field('City', _city, 'Rajkot'),
      ],
    );
  }

  Widget _field(String label, TextEditingController c, String hint,
      {TextInputType? keyboardType,
      bool readOnly = false,
      VoidCallback? onTap,
      IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: c,
            readOnly: readOnly,
            onTap: onTap,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: icon == null
                  ? null
                  : Icon(icon, size: 18, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _genderBtn(String label, IconData icon, Color color) {
    final selected = _gender == label;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() => _gender = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : AppColors.borderLight,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? color : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected ? color : AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
