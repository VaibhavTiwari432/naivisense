import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/state_widgets/loading_widget.dart';
import '../../admin/providers/child_management_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/therapist_dashboard_provider.dart';

class TherapistHome extends ConsumerStatefulWidget {
  const TherapistHome({super.key});

  @override
  ConsumerState<TherapistHome> createState() => _TherapistHomeState();
}

class _TherapistHomeState extends ConsumerState<TherapistHome> {
  late int _index = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [
      _TherapistDashboard(),
      _MyStudentsTab(),
      _PlaceholderTab(
        icon: Icons.calendar_month_rounded,
        title: 'Calendar',
        subtitle: 'Your schedule, sessions and reminders.',
      ),
      _ReportsTab(),
      _ProfileTab(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.borderLight)),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Students'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_rounded), label: 'Calendar'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Reports'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class _TherapistDashboard extends ConsumerWidget {
  const _TherapistDashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final sessionsAsync = ref.watch(upcomingSessionsProvider);
    final childrenAsync = ref.watch(childrenProvider);

    return sessionsAsync.when(
      loading: () => const LoadingWidget(message: 'Loading sessions...'),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (sessions) {
        final childMap = {
          for (final c in (childrenAsync.valueOrNull ?? [])) c.id: c
        };
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.menu_rounded),
                IconButton(
                  onPressed: () {},
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.notifications_none_rounded),
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.softCoral,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Hello ${user?.name ?? 'Doctor'} 👋',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('You have ${sessions.length} upcoming sessions',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                StatTile(
                  value: sessions.length.toString().padLeft(2, '0'),
                  label: 'Upcoming Sessions',
                  color: AppColors.primaryBlue,
                  tint: AppColors.blueTint,
                  icon: Icons.calendar_today_rounded,
                ),
                StatTile(
                  value: (childrenAsync.valueOrNull?.length ?? 0)
                      .toString()
                      .padLeft(2, '0'),
                  label: 'My Students',
                  color: AppColors.mintGreen,
                  tint: AppColors.mintTint,
                  icon: Icons.people_alt_rounded,
                ),
                const StatTile(
                  value: '—',
                  label: 'New Alerts',
                  color: AppColors.softCoral,
                  tint: AppColors.coralTint,
                  icon: Icons.notifications_active_rounded,
                ),
                const StatTile(
                  value: '—',
                  label: 'This Week Reports',
                  color: Color(0xFFB45309),
                  tint: AppColors.yellowTint,
                  icon: Icons.bar_chart_rounded,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SectionHeader(
                title: 'Upcoming Sessions', action: 'View Calendar'),
            const SizedBox(height: 8),
            if (sessions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No upcoming sessions',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              ),
            ...sessions.map((s) {
              final child = childMap[s.childId];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  onTap: () =>
                      context.push('/therapist/child/${s.childId}'),
                  child: Row(
                    children: [
                      AvatarCircle(
                          emoji: child?.photoEmoji ?? '🧒', size: 48),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(child?.fullName ?? 'Child',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(
                              '${DateFormat('h:mm a').format(s.dateTime)} • ${s.type}',
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            context.push('/therapist/session/${s.id}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mintGreen,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999)),
                          elevation: 0,
                        ),
                        child: const Text('Open',
                            style: TextStyle(
                                fontSize: 12, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _MyStudentsTab extends ConsumerWidget {
  const _MyStudentsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authProvider).user?.id;
    final childrenAsync = ref.watch(childrenProvider);
    final children = (childrenAsync.valueOrNull ?? [])
        .where((c) =>
            userId == null || c.assignedTherapistIds.contains(userId))
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
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textSecondary),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class _ReportsTab extends ConsumerWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authProvider).user?.id;
    final children = (ref.watch(childrenProvider).valueOrNull ?? [])
        .where((c) =>
            userId == null || c.assignedTherapistIds.contains(userId))
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

class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

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
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
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
                style: TextStyle(
                    color: AppColors.softCoral, fontWeight: FontWeight.w600)),
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
                child: Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary),
            ],
          ),
        ),
      );
}

class _PlaceholderTab extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _PlaceholderTab({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

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
            Text(title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
