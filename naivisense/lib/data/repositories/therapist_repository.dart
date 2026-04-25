import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../services/api_service.dart';
import '../services/error_handler_service.dart';
import '../../shared/models/therapist.dart';

final therapistRepositoryProvider = Provider<TherapistRepository>((ref) {
  return TherapistRepository(ref.read(apiServiceProvider));
});

class TherapistRepository {
  final ApiService _api;

  TherapistRepository(this._api);

  Future<Therapist> getMyProfile() async {
    try {
      final res = await _api.get<Map<String, dynamic>>(
        AppConstants.therapistProfileEndpoint,
      );
      return Therapist.fromJson(_asMap(res.data));
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<Therapist> createProfile({
    required String specialization,
    required int yearsExperience,
    required String city,
    String? bio,
    String? qualification,
    String? clinicName,
    List<String> languages = const [],
  }) async {
    try {
      final res = await _api.post<Map<String, dynamic>>(
        AppConstants.therapistProfileEndpoint,
        data: {
          'specialization': specialization,
          'years_of_experience': yearsExperience,
          if (qualification != null) 'qualification': qualification,
          if (clinicName != null) 'clinic_name': clinicName,
          'clinic_address': city,
          if (languages.isNotEmpty) 'languages': languages,
          if (bio != null) 'bio': bio,
        },
      );
      return Therapist.fromJson(_asMap(res.data));
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<Therapist> updateProfile({
    String? specialization,
    int? yearsExperience,
    String? city,
    String? bio,
    String? qualification,
    String? clinicName,
    List<String>? languages,
  }) async {
    try {
      final res = await _api.put<Map<String, dynamic>>(
        AppConstants.therapistProfileEndpoint,
        data: {
          if (specialization != null) 'specialization': specialization,
          if (yearsExperience != null) 'years_of_experience': yearsExperience,
          if (qualification != null) 'qualification': qualification,
          if (clinicName != null) 'clinic_name': clinicName,
          if (city != null) 'clinic_address': city,
          if (languages != null) 'languages': languages,
          if (bio != null) 'bio': bio,
        },
      );
      return Therapist.fromJson(_asMap(res.data));
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<List<Therapist>> getAllTherapists() async {
    throw const AppException('Therapist listing is not supported yet.');
  }

  Map<String, dynamic> _asMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const AppException('Unexpected therapist response.');
  }
}
