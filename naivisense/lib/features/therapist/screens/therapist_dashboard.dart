import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../auth/providers/auth_provider.dart';

class TherapistDashboard extends ConsumerWidget {
  const TherapistDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    // Keep sessions provider watched so edits propagate
    ref.watch(sessionsProvider);
    final user = ref.watch(authProvider).user;
    final sessions = repo.sessionsForTherapistToday('t1');

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Text(
                  'Hello ${user?.name ?? 'Dr. Sharma'} 👋',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'You have ${sessions.length} sessions today',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 20),
                _buildStatsGrid(sessions.length),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Upcoming Sessions',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View Calendar',
                          style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...sessions.map((s) {
                  final child = repo.childById(s.childId);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      onTap: () => context.push('/therapist/child/${s.childId}'),
                      child: Row(
                        children: [
                          AvatarCircle(
                            emoji: child?.photoEmoji ?? '🧒',
                            size: 48,
                            backgroundColor: AppColors.blueTint,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(child?.fullName ?? 'Child',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                const SizedBox(height: 2),
                                Text(
                                  '${DateFormat('h:mm a').format(s.dateTime)} • ${s.type}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => context.push('/therapist/session/${s.id}'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.mintGreen,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              elevation: 0,
                            ),
                            child: const Text('Confirm',
                                style: TextStyle(fontSize: 12, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(int todaySessions) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        StatTile(
          value: todaySessions.toString().padLeft(2, '0'),
          label: "Today's Sessions",
          color: AppColors.primaryBlue,
          tint: AppColors.blueTint,
          icon: Icons.calendar_today_rounded,
        ),
        const StatTile(
          value: '03',
          label: 'Pending Feedback',
          color: Color(0xFFB45309),
          tint: AppColors.yellowTint,
          icon: Icons.edit_note_rounded,
        ),
        const StatTile(
          value: '01',
          label: 'New Alerts',
          color: AppColors.softCoral,
          tint: AppColors.coralTint,
          icon: Icons.notifications_active_rounded,
        ),
        const StatTile(
          value: '12',
          label: 'This Week Reports',
          color: AppColors.mintGreen,
          tint: AppColors.mintTint,
          icon: Icons.bar_chart_rounded,
        ),
      ],
    );
  }
}
