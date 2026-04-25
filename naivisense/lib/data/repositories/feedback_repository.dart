import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../services/api_service.dart';
import '../services/error_handler_service.dart';
import '../../shared/models/session.dart';
import '../../shared/models/api/session_requests.dart';

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  return FeedbackRepository(ref.read(apiServiceProvider));
});

class FeedbackRepository {
  final ApiService _api;

  FeedbackRepository(this._api);

  Future<List<ParentFeedback>> getFeedback({String? childId}) async {
    if (childId == null || childId.isEmpty) {
      throw const AppException('Child id is required for feedback history.');
    }

    try {
      final res = await _api.get<List<dynamic>>(
        AppConstants.feedbackHistoryEndpoint(childId),
      );
      return (res.data ?? const [])
          .map((item) => ParentFeedback.fromJson(_asMap(item)))
          .toList();
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<ParentFeedback> createFeedback(FeedbackCreateRequest request) async {
    try {
      final res = await _api.post<Map<String, dynamic>>(
        AppConstants.feedbackDailyEndpoint,
        data: request.toJson(),
      );
      return ParentFeedback.fromJson(_asMap(res.data));
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<ParentFeedback> submitDailyFeedback(
    FeedbackCreateRequest request,
  ) =>
      createFeedback(request);

  Map<String, dynamic> _asMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const AppException('Unexpected feedback response.');
  }
}
