import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../shared/models/api/session_requests.dart';
import '../../../shared/models/session.dart';

class SessionNotesNotifier
    extends FamilyAsyncNotifier<SessionNotes?, String> {
  @override
  Future<SessionNotes?> build(String sessionId) async => null;

  Future<bool> submit(SessionNotesRequest request) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(sessionRepositoryProvider).addNotes(arg, request),
    );
    state = result;
    return result is AsyncData;
  }
}

final sessionNotesNotifierProvider = AsyncNotifierProvider.family<
    SessionNotesNotifier, SessionNotes?, String>(SessionNotesNotifier.new);
