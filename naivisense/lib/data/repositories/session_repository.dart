import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../services/api_service.dart';
import '../services/error_handler_service.dart';
import '../../shared/models/session.dart';
import '../../shared/models/api/session_requests.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(ref.read(apiServiceProvider));
});

class SessionRepository {
  final ApiService _api;

  SessionRepository(this._api);

  Future<List<Session>> getSessions({String? childId}) async {
    try {
      final res = await _api.get<List<dynamic>>(
        AppConstants.sessionsEndpoint,
      );
      final sessions = (res.data ?? const [])
          .map((item) => Session.fromJson(_asMap(item)))
          .toList();
      if (childId == null) return sessions;
      return sessions.where((session) => session.childId == childId).toList();
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<List<Session>> getUpcomingSessions() async {
    try {
      final res = await _api.get<List<dynamic>>(
        AppConstants.upcomingSessionsEndpoint,
      );
      return (res.data ?? const [])
          .map((item) => Session.fromJson(_asMap(item)))
          .toList();
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<Session> getSession(String id) async {
    final sessions = await getSessions();
    return sessions.firstWhere(
      (session) => session.id == id,
      orElse: () => throw const AppException('Session not found.'),
    );
  }

  Future<Session> createSession(SessionCreateRequest request) async {
    try {
      final res = await _api.post<Map<String, dynamic>>(
        AppConstants.sessionsEndpoint,
        data: request.toJson(),
      );
      return Session.fromJson(_asMap(res.data));
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<Session> updateSessionStatus(String id, String status) async {
    if (status.toLowerCase() == SessionStatus.completed.name) {
      return completeSession(id);
    }
    throw const AppException('Only completing sessions is supported yet.');
  }

  Future<Session> completeSession(String id) async {
    try {
      final res = await _api.post<Map<String, dynamic>>(
        AppConstants.completeSessionEndpoint(id),
      );
      return Session.fromJson(_asMap(res.data));
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<SessionNotes> addNotes(
    String sessionId,
    SessionNotesRequest notes,
  ) async {
    try {
      final res = await _api.post<Map<String, dynamic>>(
        AppConstants.sessionNotesEndpoint(sessionId),
        data: notes.toJson(),
      );
      return SessionNotes.fromJson(_asMap(res.data));
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<SessionNotes> getNotes(String sessionId) async {
    try {
      final res = await _api.get<Map<String, dynamic>>(
        AppConstants.sessionNotesEndpoint(sessionId),
      );
      return SessionNotes.fromJson(_asMap(res.data));
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Map<String, dynamic> _asMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const AppException('Unexpected session response.');
  }
}
