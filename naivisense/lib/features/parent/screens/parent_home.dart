import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/parent_dashboard_provider.dart';

class ParentHome extends ConsumerStatefulWidget {
  const ParentHome({super.key});

  @override
  ConsumerState<ParentHome> createState() => _ParentHomeState();
}

class _ParentHomeState extends ConsumerState<ParentHome> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [
      ParentDashboard(),
      _ParentTasksScreen(),
      _ParentProgressScreen(),
      _ParentAlertsScreen(),
      _ParentProfileScreen(),
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
          selectedItemColor: AppColors.mintGreen,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.checklist_rounded), label: 'Tasks'),
            BottomNavigationBarItem(icon: Icon(Icons.trending_up_rounded), label: 'Progress'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_active_rounded), label: 'Alerts'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class ParentDashboard extends ConsumerWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final sessionsAsync = ref.watch(parentUpcomingSessionsProvider);

    final sessions = sessionsAsync.valueOrNull ?? [];
    final nextSession = sessions.isNotEmpty ? sessions.first : null;

    const tasks = <dynamic>[];
    const completedCount = 0;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.menu_rounded),
            IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Good Evening,\n${user?.name ?? "Mrs. Priya Singh"} 👋',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
        ),
        const SizedBox(height: 20),
        AppCard(
          backgroundColor: AppColors.yellowTint,
          border: Border.all(color: AppColors.warmYellow.withValues(alpha: 0.4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('📅', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 10),
                  const Text("Today's Therapy",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                nextSession != null
                    ? DateFormat('h:mm a').format(nextSession.dateTime)
                    : 'No session today',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                nextSession != null
                    ? '${nextSession.type} session'
                    : 'Enjoy your day!',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: const Text('View Details →',
                    style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Today's Tasks",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text(
              '$completedCount of ${tasks.length} Completed',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (tasks.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('No tasks assigned yet',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mintGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          onPressed: () => context.push('/parent/feedback'),
          icon: const Icon(Icons.edit_note_rounded),
          label: const Text('Submit Daily Feedback',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _ParentTasksScreen extends ConsumerWidget {
  const _ParentTasksScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('All Tasks',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'Tasks will appear here once your therapist assigns them.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _ParentProgressScreen extends StatelessWidget {
  const _ParentProgressScreen();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Progress', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('See how Aarav is doing.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 20),
          AppCard(
            onTap: () => context.push('/parent/report/c1'),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.mintTint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.trending_up_rounded, color: AppColors.mintGreen),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('View Full Progress Report',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(height: 2),
                      Text('Weekly trends, attendance & therapist notes',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ParentAlertsScreen extends StatelessWidget {
  const _ParentAlertsScreen();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Alerts & Reports',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('Raise an urgent issue or view alerts',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 20),
        AppCard(
          backgroundColor: AppColors.coralTint,
          border: Border.all(color: AppColors.softCoral.withValues(alpha: 0.4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Raise Urgent Issue',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 4),
              const Text(
                'Report fever, regression, aggression, sleep issue, or any unusual observation.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.softCoral,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report submitted to therapist')),
                  );
                },
                child: const Text('Report Now', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ParentProfileScreen extends ConsumerWidget {
  const _ParentProfileScreen();

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
                emoji: user?.avatarEmoji ?? '👩',
                size: 88,
                backgroundColor: AppColors.mintTint,
              ),
              const SizedBox(height: 12),
              Text(user?.name ?? 'Parent',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 20),
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
}
