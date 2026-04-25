import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../shared/models/api/session_requests.dart';
import '../../admin/providers/child_management_provider.dart';
import '../providers/feedback_provider.dart';

class ParentFeedbackScreen extends ConsumerStatefulWidget {
  const ParentFeedbackScreen({super.key});

  @override
  ConsumerState<ParentFeedbackScreen> createState() => _ParentFeedbackScreenState();
}

class _ParentFeedbackScreenState extends ConsumerState<ParentFeedbackScreen> {
  int _sleep = 4;
  int _appetite = 3;
  int _communication = 4;
  int _meltdown = 2;
  final _notesCtrl = TextEditingController(
    text: 'He was a little restless in the evening but practiced well.',
  );

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final children = ref.read(childrenProvider).valueOrNull ?? [];
    if (children.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No child profile found for your account')),
      );
      return;
    }
    final childId = children.first.id;

    final request = FeedbackCreateRequest(
      childId: childId,
      sleepQuality: _sleep,
      appetite: _appetite,
      communication: _communication,
      meltdown: _meltdown,
      notes: _notesCtrl.text.trim(),
      feedbackDate: DateTime.now().toIso8601String().split('T').first,
    );

    final ok = await ref.read(feedbackNotifierProvider.notifier).submit(request);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted to therapist')),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit. Please retry.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daily Feedback'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              "How was Aarav's day?",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _row('Sleep Quality', _sleep, (v) => setState(() => _sleep = v)),
            _row('Appetite', _appetite, (v) => setState(() => _appetite = v)),
            _row('Communication', _communication, (v) => setState(() => _communication = v)),
            _row('Meltdown / Tantrum', _meltdown, (v) => setState(() => _meltdown = v)),
            const SizedBox(height: 16),
            const Text('Anything unusual or we should know?',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesCtrl,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Type your note...'),
            ),
            const SizedBox(height: 24),
            AppButton(label: 'Submit Feedback', variant: AppButtonVariant.success, onPressed: _submit),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, int value, void Function(int) onChanged) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            RatingStars(value: value, onChanged: onChanged),
          ],
        ),
      );
}
