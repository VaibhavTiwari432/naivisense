import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../shared/models/session.dart';

// Returns upcoming sessions visible to the current user (parent or therapist).
final parentUpcomingSessionsProvider = FutureProvider<List<Session>>((ref) {
  return ref.read(sessionRepositoryProvider).getUpcomingSessions();
});
