import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/therapist.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/child_management_provider.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = ref.watch(childrenProvider).valueOrNull ?? [];
    final therapists = ref.watch(therapistsListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Admin Console',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                    context.go('/');
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text('Manage therapists, children & assignments',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    value: '${therapists.length}',
                    label: 'Therapists',
                    color: AppColors.primaryBlue,
                    tint: AppColors.blueTint,
                    icon: Icons.medical_services_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    value: '${children.length}',
                    label: 'Children',
                    color: AppColors.mintGreen,
                    tint: AppColors.mintTint,
                    icon: Icons.child_care_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Add Child',
                    icon: Icons.add_rounded,
                    onPressed: () => context.push('/admin/add-child'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    label: 'Add Therapist',
                    icon: Icons.person_add_rounded,
                    variant: AppButtonVariant.success,
                    onPressed: () => context.push('/admin/add-therapist'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Children'),
            const SizedBox(height: 10),
            ...children.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    onTap: () => context.push('/admin/assign/${c.id}'),
                    child: Row(
                      children: [
                        AvatarCircle(emoji: c.photoEmoji),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.fullName,
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text(
                                '${c.assignedTherapistIds.length} therapist(s) assigned',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Therapists'),
            const SizedBox(height: 10),
            ...therapists.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    child: Row(
                      children: [
                        AvatarCircle(emoji: t.avatarEmoji, backgroundColor: AppColors.blueTint),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.fullName,
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text(
                                '${t.specialization} • ${t.yearsExperience} yrs',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class AddTherapistScreen extends ConsumerStatefulWidget {
  const AddTherapistScreen({super.key});

  @override
  ConsumerState<AddTherapistScreen> createState() => _AddTherapistScreenState();
}

class _AddTherapistScreenState extends ConsumerState<AddTherapistScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _city = TextEditingController();
  String _specialization = 'Speech Therapy';
  int _experience = 3;

  static const _specializations = [
    'Speech Therapy',
    'Occupational Therapy',
    'Special Educator',
    'Physiotherapy',
    'Autism Expert',
  ];

  @override
  void dispose() {
    for (final c in [_name, _phone, _email, _city]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (_name.text.isEmpty || _phone.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Fill name and phone')));
      return;
    }
    final t = Therapist(
      id: 't${DateTime.now().millisecondsSinceEpoch}',
      fullName: _name.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      specialization: _specialization,
      yearsExperience: _experience,
      city: _city.text.trim(),
      avatarEmoji: '🧑‍⚕️',
    );
    ref.read(therapistsListProvider.notifier).add(t);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${t.fullName} added')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Add Therapist')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _field('Full Name', _name, 'Dr. Name'),
            _field('Phone', _phone, '+91 98765 43210',
                keyboardType: TextInputType.phone),
            _field('Email', _email, 'name@clinic.in',
                keyboardType: TextInputType.emailAddress),
            _field('City', _city, 'Rajkot'),
            const SizedBox(height: 4),
            const Text('Specialization',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _specializations
                  .map((s) => StatusChip(
                        label: s,
                        color: AppColors.primaryBlue,
                        selected: _specialization == s,
                        onTap: () => setState(() => _specialization = s),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text('Years of experience: $_experience',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Slider(
              value: _experience.toDouble(),
              min: 0,
              max: 30,
              divisions: 30,
              activeColor: AppColors.primaryBlue,
              onChanged: (v) => setState(() => _experience = v.toInt()),
            ),
            const SizedBox(height: 20),
            AppButton(label: 'Save Therapist', onPressed: _save),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, String hint,
      {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: c,
            keyboardType: keyboardType,
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }
}

class AssignTherapistScreen extends ConsumerStatefulWidget {
  final String childId;
  const AssignTherapistScreen({super.key, required this.childId});

  @override
  ConsumerState<AssignTherapistScreen> createState() => _AssignTherapistScreenState();
}

class _AssignTherapistScreenState extends ConsumerState<AssignTherapistScreen> {
  Set<String> _selected = {};
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final allChildren = ref.watch(childrenProvider).valueOrNull ?? [];
    final child = allChildren.cast<dynamic>().firstWhere(
          (c) => c.id == widget.childId,
          orElse: () => null,
        );
    final therapists = ref.watch(therapistsListProvider);
    if (child == null) return const SizedBox();

    if (!_initialized) {
      _selected = {...child.assignedTherapistIds};
      _initialized = true;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Assign Therapists')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: AppCard(
                child: Row(
                  children: [
                    AvatarCircle(emoji: child.photoEmoji, size: 48),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(child.fullName,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text('${child.ageInYears} yrs • ${child.severity}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: therapists.map((t) {
                  final selected = _selected.contains(t.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      onTap: () => setState(() {
                        selected ? _selected.remove(t.id) : _selected.add(t.id);
                      }),
                      border: Border.all(
                        color: selected ? AppColors.primaryBlue : AppColors.borderLight,
                        width: selected ? 1.5 : 1,
                      ),
                      child: Row(
                        children: [
                          AvatarCircle(emoji: t.avatarEmoji),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t.fullName,
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                                Text(t.specialization,
                                    style: const TextStyle(
                                        fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Icon(
                            selected
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: selected ? AppColors.primaryBlue : AppColors.borderLight,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: AppButton(
                label: 'Save Assignment',
                onPressed: () async {
                  if (_selected.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Select at least one therapist')),
                    );
                    return;
                  }
                  final ok = await ref
                      .read(childrenProvider.notifier)
                      .assignTherapist(widget.childId, _selected.first);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok ? 'Assignment saved' : 'Failed to save. Please retry.'),
                    ),
                  );
                  if (ok) context.pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
