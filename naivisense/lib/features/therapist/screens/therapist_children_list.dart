import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../auth/providers/auth_provider.dart';

class TherapistChildrenList extends ConsumerWidget {
  const TherapistChildrenList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = ref.watch(childrenListProvider)
        .where((c) => c.assignedTherapistIds.contains('t1'))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('My Students',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('${children.length} children under your care',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 20),
        ...children.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                onTap: () => context.push('/therapist/child/${c.id}'),
                child: Row(
                  children: [
                    AvatarCircle(emoji: c.photoEmoji, size: 52),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.fullName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 15)),
                          const SizedBox(height: 2),
                          Text(
                            '${c.ageInYears} yrs • ${c.diagnoses.join(", ")}',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: c.therapyTargets
                                .take(2)
                                .map((t) => StatusChip(
                                      label: t,
                                      color: AppColors.primaryBlue,
                                      selected: true,
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class TherapistCalendar extends ConsumerWidget {
  const TherapistCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _PlaceholderScreen(
      title: 'Calendar',
      subtitle: 'Your schedule, sessions and reminders',
      icon: Icons.calendar_month_rounded,
    );
  }
}

class TherapistReports extends ConsumerWidget {
  const TherapistReports({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = ref.watch(childrenListProvider)
        .where((c) => c.assignedTherapistIds.contains('t1'))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Reports',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('Monthly progress reports for each child',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 20),
        ...children.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                onTap: () => context.push('/therapist/report/${c.id}'),
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
                          const SizedBox(height: 4),
                          const Text('Last 4 weeks • 12 sessions',
                              style: TextStyle(
                                  color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    const StatusChip(
                      label: 'Improving',
                      color: AppColors.mintGreen,
                      selected: true,
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class TherapistProfile extends ConsumerWidget {
  const TherapistProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: Column(
            children: [
              AvatarCircle(
                emoji: user?.avatarEmoji ?? '👨‍⚕️',
                size: 88,
                backgroundColor: AppColors.blueTint,
              ),
              const SizedBox(height: 12),
              Text(user?.name ?? 'Therapist',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(user?.email ?? '',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _menuTile(Icons.person_outline_rounded, 'Account Settings'),
        _menuTile(Icons.lock_outline_rounded, 'Privacy & Security'),
        _menuTile(Icons.folder_copy_outlined, 'Resource Vault'),
        _menuTile(Icons.help_outline_rounded, 'Help & Support'),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            ref.read(authProvider.notifier).logout();
            context.go('/');
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            child: const Text('Logout',
                style: TextStyle(color: AppColors.softCoral, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _menuTile(IconData icon, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      );
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _PlaceholderScreen({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.blueTint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: AppColors.primaryBlue, size: 32),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
