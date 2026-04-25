import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../services/api_service.dart';
import '../services/error_handler_service.dart';
import '../../shared/models/child.dart';
import '../../shared/models/api/child_requests.dart';

final childRepositoryProvider = Provider<ChildRepository>((ref) {
  return ChildRepository(ref.read(apiServiceProvider));
});

class ChildRepository {
  final ApiService _api;

  ChildRepository(this._api);

  Future<List<Child>> getChildren() async {
    try {
      final res = await _api.get<List<dynamic>>(AppConstants.childrenEndpoint);
      return (res.data ?? const [])
          .map((item) => Child.fromJson(_asMap(item)))
          .toList();
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<Child> getChild(String id) async {
    try {
      final res = await _api.get<Map<String, dynamic>>(
        AppConstants.childEndpoint(id),
      );
      return Child.fromJson(_asMap(res.data));
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<Child> createChild(ChildCreateRequest request) async {
    try {
      final res = await _api.post<Map<String, dynamic>>(
        AppConstants.childrenEndpoint,
        data: request.toJson(),
      );
      return Child.fromJson(_asMap(res.data));
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<Child> updateChild(String id, ChildUpdateRequest request) async {
    try {
      final res = await _api.put<Map<String, dynamic>>(
        AppConstants.childEndpoint(id),
        data: request.toJson(),
      );
      return Child.fromJson(_asMap(res.data));
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<void> deleteChild(String id) async {
    throw const AppException('Deleting child profiles is not supported yet.');
  }

  Future<Child> assignTherapist(String childId, String therapistId) async {
    return updateChild(
      childId,
      ChildUpdateRequest(therapistId: therapistId),
    );
  }

  Map<String, dynamic> _asMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const AppException('Unexpected child response.');
  }
}
