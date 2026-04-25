import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/session.dart';
import '../../../shared/models/api/session_requests.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../providers/session_provider.dart';
import '../providers/therapist_dashboard_provider.dart';

class SessionNotesScreen extends ConsumerStatefulWidget {
  final String sessionId;
  const SessionNotesScreen({super.key, required this.sessionId});

  @override
  ConsumerState<SessionNotesScreen> createState() => _SessionNotesScreenState();
}

class _SessionNotesScreenState extends ConsumerState<SessionNotesScreen> {
  SessionMood _mood = SessionMood.happy;
  int _attention = 4;
  int _communication = 4;
  int _motor = 4;
  int _behavior = 3;
  final Set<String> _activities = {'Ball Play', 'Sound Imitation'};
  final _notesCtrl = TextEditingController(
    text: 'Aarav was more engaged today. He tried repeating words clearly. Need to work on eye contact.',
  );

  static const _activitiesPool = ['Ball Play', 'Sound Imitation', 'Fine Motor', 'Breathing Exercise'];

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final request = SessionNotesRequest(
      mood: _mood.name,
      attention: _attention,
      communication: _communication,
      motorSkills: _motor,
      behavior: _behavior,
      activitiesDone: _activities.toList(),
      notes: _notesCtrl.text.trim(),
    );
    final ok = await ref
        .read(sessionNotesNotifierProvider(widget.sessionId).notifier)
        .submit(request);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session notes saved')),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save notes. Please retry.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesState = ref.watch(sessionNotesNotifierProvider(widget.sessionId));
    final sessions = ref.watch(upcomingSessionsProvider).valueOrNull ?? [];
    final session = sessions.cast<Session?>().firstWhere(
          (s) => s?.id == widget.sessionId,
          orElse: () => null,
        );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Session Notes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: notesState.isLoading ? null : () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              session != null
                  ? 'Session • ${DateFormat('h:mm a').format(session.dateTime)}'
                  : 'Session Notes',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Session Summary'),
            const SizedBox(height: 12),
            const Text('Mood Today',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                _moodTile(SessionMood.sad, '😢', 'Sad'),
                const SizedBox(width: 10),
                _moodTile(SessionMood.calm, '😐', 'Calm'),
                const SizedBox(width: 10),
                _moodTile(SessionMood.happy, '😊', 'Happy'),
              ],
            ),
            const SizedBox(height: 20),
            _ratingRow('Attention', _attention, (v) => setState(() => _attention = v)),
            _ratingRow('Communication', _communication, (v) => setState(() => _communication = v)),
            _ratingRow('Motor Skills', _motor, (v) => setState(() => _motor = v)),
            _ratingRow('Behavior', _behavior, (v) => setState(() => _behavior = v)),
            const SizedBox(height: 16),
            const Text('Activities Done',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _activitiesPool
                  .map((a) => StatusChip(
                        label: a,
                        color: AppColors.primaryBlue,
                        selected: _activities.contains(a),
                        onTap: () => setState(() {
                          _activities.contains(a) ? _activities.remove(a) : _activities.add(a);
                        }),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            const Text('Notes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesCtrl,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Add any additional notes...'),
            ),
            const SizedBox(height: 20),
            AppButton(label: 'Save Notes', onPressed: _save),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _moodTile(SessionMood m, String emoji, String label) {
    final selected = _mood == m;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mood = m),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.mintTint : AppColors.cardSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.mintGreen : AppColors.borderLight,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: selected ? AppColors.mintGreen : AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ratingRow(String label, int value, void Function(int) onChanged) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            RatingStars(value: value, onChanged: onChanged),
          ],
        ),
      );
}
