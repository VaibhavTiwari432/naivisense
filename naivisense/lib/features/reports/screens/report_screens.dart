import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../shared/widgets/state_widgets/loading_widget.dart';
import '../../admin/providers/child_management_provider.dart';
import '../providers/progress_report_provider.dart';

class WeeklyFeedbackScreen extends ConsumerStatefulWidget {
  final String childId;
  const WeeklyFeedbackScreen({super.key, required this.childId});

  @override
  ConsumerState<WeeklyFeedbackScreen> createState() => _WeeklyFeedbackScreenState();
}

class _WeeklyFeedbackScreenState extends ConsumerState<WeeklyFeedbackScreen> {
  int _speech = 4, _focus = 4, _social = 3, _motor = 4;
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Weekly Feedback'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Rate this week (1-5 scale)',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            _row('Speech Progress', _speech, (v) => setState(() => _speech = v)),
            _row('Focus / Attention', _focus, (v) => setState(() => _focus = v)),
            _row('Social Interaction', _social, (v) => setState(() => _social = v)),
            _row('Motor Skills', _motor, (v) => setState(() => _motor = v)),
            const SizedBox(height: 12),
            const Text('Written Updates',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesCtrl,
              maxLines: 5,
              decoration:
                  const InputDecoration(hintText: 'What did we work on this week?'),
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'Submit Weekly Feedback',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Weekly feedback submitted')),
                );
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, int value, void Function(int) onChanged) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              RatingStars(value: value, onChanged: onChanged),
            ],
          ),
        ),
      );
}

class ProgressReportScreen extends ConsumerWidget {
  final String childId;
  const ProgressReportScreen({super.key, required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childAsync = ref.watch(childProvider(childId));
    final reportAsync = ref.watch(progressReportProvider(childId));

    if (childAsync.isLoading) {
      return const Scaffold(body: LoadingWidget(message: 'Loading report...'));
    }
    final child = childAsync.valueOrNull;
    if (child == null) return const Scaffold(body: Center(child: Text('Child not found')));

    final report = reportAsync.valueOrNull;

    if (report == null || report.sessionsCompleted == 0) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Progress Report'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(child.fullName,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text(
                    'Progress report not yet available.\nComplete a few sessions to generate insights.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Progress Report'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(child.fullName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Last 4 Weeks',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    value: '${report.attendancePercent}%',
                    label: 'Attendance',
                    color: AppColors.primaryBlue,
                    tint: AppColors.blueTint,
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatTile(
                    value: report.averageProgress.toStringAsFixed(1),
                    label: 'Avg. Progress',
                    color: AppColors.mintGreen,
                    tint: AppColors.mintTint,
                    icon: Icons.trending_up_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatTile(
                    value: '${report.sessionsCompleted}',
                    label: 'Sessions',
                    color: const Color(0xFFB45309),
                    tint: AppColors.yellowTint,
                    icon: Icons.event_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Speech Progress',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 160,
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 5,
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 26,
                              interval: 1,
                              getTitlesWidget: (v, _) {
                                final i = v.toInt();
                                if (i < 0 || i >= report.speechTrend.length) {
                                  return const SizedBox();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    report.speechTrend[i].label,
                                    style: const TextStyle(
                                        fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            color: AppColors.primaryBlue,
                            barWidth: 3,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                                radius: 4,
                                color: AppColors.primaryBlue,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.primaryBlue.withValues(alpha: 0.15),
                            ),
                            spots: [
                              for (var i = 0; i < report.speechTrend.length; i++)
                                FlSpot(i.toDouble(), report.speechTrend[i].score),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              backgroundColor: AppColors.mintTint,
              border: Border.all(color: AppColors.mintGreen.withValues(alpha: 0.3)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Therapist Note',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(report.therapistNote,
                      style: const TextStyle(fontSize: 13, height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'Download Report PDF',
              icon: Icons.file_download_outlined,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report downloaded (mock)')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
