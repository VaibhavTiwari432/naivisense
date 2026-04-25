import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/error_handler_service.dart';
import '../../../shared/models/session.dart';

final progressReportProvider =
    FutureProvider.family<ProgressReport?, String>((ref, childId) async {
  try {
    final api = ref.read(apiServiceProvider);
    final res = await api.get<Map<String, dynamic>>(
      AppConstants.progressReportEndpoint(childId),
    );
    final data = res.data;
    if (data == null) return null;
    return ProgressReport.fromJson(data);
  } catch (e) {
    throw ErrorHandlerService.handle(e);
  }
});

final feedbackHistoryProvider =
    FutureProvider.family<List<ParentFeedback>, String>((ref, childId) async {
  try {
    final api = ref.read(apiServiceProvider);
    final res = await api.get<List<dynamic>>(
      AppConstants.feedbackHistoryEndpoint(childId),
    );
    return (res.data ?? [])
        .map((item) {
          final m = item is Map<String, dynamic>
              ? item
              : Map<String, dynamic>.from(item as Map);
          return ParentFeedback.fromJson(m);
        })
        .toList();
  } catch (e) {
    throw ErrorHandlerService.handle(e);
  }
});

final tasksForChildProvider =
    FutureProvider.family<List<TherapyTask>, String>((ref, childId) async {
  try {
    final api = ref.read(apiServiceProvider);
    final res = await api.get<List<dynamic>>(
      '${AppConstants.tasksEndpoint}?child_id=$childId',
    );
    return (res.data ?? [])
        .map((item) {
          final m = item is Map<String, dynamic>
              ? item
              : Map<String, dynamic>.from(item as Map);
          return TherapyTask.fromJson(m);
        })
        .toList();
  } catch (e) {
    throw ErrorHandlerService.handle(e);
  }
});
