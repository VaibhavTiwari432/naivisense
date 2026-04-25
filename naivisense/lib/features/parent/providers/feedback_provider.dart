import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/feedback_repository.dart';
import '../../../shared/models/api/session_requests.dart';
import '../../../shared/models/session.dart';

class FeedbackNotifier extends AsyncNotifier<ParentFeedback?> {
  @override
  Future<ParentFeedback?> build() async => null;

  Future<bool> submit(FeedbackCreateRequest request) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(feedbackRepositoryProvider).createFeedback(request),
    );
    state = result;
    return result is AsyncData;
  }
}

final feedbackNotifierProvider =
    AsyncNotifierProvider<FeedbackNotifier, ParentFeedback?>(
        FeedbackNotifier.new);
