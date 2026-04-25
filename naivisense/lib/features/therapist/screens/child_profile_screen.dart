import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../shared/widgets/state_widgets/loading_widget.dart';
import '../../admin/providers/child_management_provider.dart';
import '../../reports/providers/progress_report_provider.dart';
import '../providers/therapist_dashboard_provider.dart';

class ChildProfileScreen extends ConsumerStatefulWidget {
  final String childId;
  const ChildProfileScreen({super.key, required this.childId});

  @override
  ConsumerState<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends ConsumerState<ChildProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 5, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final childAsync = ref.watch(childProvider(widget.childId));
    if (childAsync.isLoading) {
      return const Scaffold(body: LoadingWidget(message: 'Loading profile...'));
    }
    final child = childAsync.valueOrNull;
    if (child == null) {
      return const Scaffold(body: Center(child: Text('Child not found')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Child Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(160),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      AvatarCircle(emoji: child.photoEmoji, size: 56),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(child.fullName,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(
                                '${child.ageInYears} yrs • ${child.gender} • ${child.severity}',
                                style: const TextStyle(
                                    color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                      StatusChip(
                        label: child.diagnoses.first,
                        color: AppColors.primaryBlue,
                        selected: true,
                      ),
                    ],
                  ),
                ),
              ),
              TabBar(
                controller: _tab,
                isScrollable: true,
                indicatorColor: AppColors.primaryBlue,
                labelColor: AppColors.primaryBlue,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Schedule'),
                  Tab(text: 'Tasks'),
                  Tab(text: 'Diet'),
                  Tab(text: 'Feedback'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _OverviewTab(childId: child.id),
          _ScheduleTab(childId: child.id),
          _TasksTab(childId: child.id),
          const _DietTab(),
          _FeedbackTab(childId: child.id),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/therapist/feedback/${child.id}'),
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
        label: const Text('Weekly Feedback', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  final String childId;
  const _OverviewTab({required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(childProvider(childId)).valueOrNull;
    if (child == null) return const SizedBox();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SectionHeader(title: 'Therapy Targets'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: child.therapyTargets
              .map((t) => StatusChip(label: t, color: AppColors.primaryBlue, selected: true))
              .toList(),
        ),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Parents & Contact'),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            children: [
              _row(Icons.person_outline_rounded, 'Mother', child.motherName),
              const Divider(),
              _row(Icons.person_outline_rounded, 'Father', child.fatherName),
              const Divider(),
              _row(Icons.phone_outlined, 'Contact', child.contactNumber),
              const Divider(),
              _row(Icons.location_on_outlined, 'City', child.city),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Diagnosis'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: child.diagnoses
              .map((d) => StatusChip(label: d, color: AppColors.softCoral, selected: true))
              .toList(),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _row(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Text(label,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const Spacer(),
            Flexible(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      );
}

class _ScheduleTab extends ConsumerWidget {
  final String childId;
  const _ScheduleTab({required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = (ref.watch(upcomingSessionsProvider).valueOrNull ?? [])
        .where((s) => s.childId == childId)
        .toList();
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: sessions.length,
      itemBuilder: (_, i) {
        final s = sessions[i];
        return AppCard(
          onTap: () => context.push('/therapist/session/${s.id}'),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: AppColors.blueTint, borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: const Icon(Icons.event_rounded, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.type,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('EEE, MMM d • h:mm a').format(s.dateTime),
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              StatusChip(
                label: s.status.name,
                color: s.status.name == 'completed'
                    ? AppColors.mintGreen
                    : s.status.name == 'missed'
                        ? AppColors.softCoral
                        : AppColors.primaryBlue,
                selected: true,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TasksTab extends ConsumerWidget {
  final String childId;
  const _TasksTab({required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksForChildProvider(childId));
    return tasksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Could not load tasks: $e',
              style: const TextStyle(color: AppColors.textSecondary)),
        ),
      ),
      data: (tasks) {
        if (tasks.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No tasks assigned yet.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemCount: tasks.length,
          itemBuilder: (_, i) {
            final t = tasks[i];
            return AppCard(
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: t.completed ? AppColors.mintTint : AppColors.yellowTint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      t.completed ? Icons.check_rounded : Icons.assignment_rounded,
                      color: t.completed ? AppColors.mintGreen : const Color(0xFFB45309),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.title,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        if (t.description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(t.description,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                          ),
                      ],
                    ),
                  ),
                  StatusChip(
                    label: t.status,
                    color: t.completed ? AppColors.mintGreen : AppColors.primaryBlue,
                    selected: true,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _DietTab extends StatelessWidget {
  const _DietTab();

  @override
  Widget build(BuildContext context) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final meals = ['Warm water + dates', 'Oats porridge + banana', 'Dal rice + ghee'];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SectionHeader(title: 'Weekly Diet Plan'),
        const SizedBox(height: 12),
        ...days.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ...meals.map((m) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.restaurant_rounded,
                                  size: 14, color: AppColors.mintGreen),
                              const SizedBox(width: 8),
                              Text(m,
                                  style: const TextStyle(
                                      fontSize: 13, color: AppColors.textSecondary)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class _FeedbackTab extends ConsumerWidget {
  final String childId;
  const _FeedbackTab({required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedbackAsync = ref.watch(feedbackHistoryProvider(childId));
    return feedbackAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Could not load feedback: $e',
              style: const TextStyle(color: AppColors.textSecondary)),
        ),
      ),
      data: (feedbacks) {
        if (feedbacks.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No parent feedback submitted yet.\nParents can submit daily feedback.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemCount: feedbacks.length,
          itemBuilder: (_, i) {
            final f = feedbacks[i];
            return AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('EEE, MMM d').format(f.date),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          const Icon(Icons.mood_rounded,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('Sleep: ${f.sleepQuality}/5  '
                              'Appetite: ${f.appetite}/5',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  if (f.notes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(f.notes,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}
