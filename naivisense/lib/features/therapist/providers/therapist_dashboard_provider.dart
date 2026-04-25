import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../shared/models/session.dart';

final upcomingSessionsProvider = FutureProvider<List<Session>>((ref) {
  return ref.read(sessionRepositoryProvider).getUpcomingSessions();
});
