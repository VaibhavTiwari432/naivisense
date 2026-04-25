class Therapist {
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final String specialization;
  final int yearsExperience;
  final String city;
  final String? avatarEmoji;
  final String? qualification;
  final String? clinicName;
  final String? clinicAddress;
  final List<String> languages;
  final double rating;
  final int totalSessions;

  const Therapist({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.specialization,
    required this.yearsExperience,
    required this.city,
    this.avatarEmoji,
    this.qualification,
    this.clinicName,
    this.clinicAddress,
    this.languages = const [],
    this.rating = 0,
    this.totalSessions = 0,
  });

  factory Therapist.fromJson(Map<String, dynamic> json) => Therapist(
        id: json['user_id'] as String? ?? json['id'] as String,
        fullName: json['full_name'] as String? ??
            json['name'] as String? ??
            json['user']?['name'] as String? ??
            json['user']?['full_name'] as String? ??
            '',
        phone:
            json['phone'] as String? ?? json['user']?['phone'] as String? ?? '',
        email:
            json['email'] as String? ?? json['user']?['email'] as String? ?? '',
        specialization: json['specialization'] as String? ?? '',
        yearsExperience: json['years_of_experience'] as int? ??
            json['years_experience'] as int? ??
            0,
        city:
            json['city'] as String? ?? json['clinic_address'] as String? ?? '',
        qualification: json['qualification'] as String?,
        clinicName: json['clinic_name'] as String?,
        clinicAddress: json['clinic_address'] as String?,
        languages: List<String>.from(json['languages'] as List? ?? []),
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        totalSessions: json['total_sessions'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'user_id': id,
        'specialization': specialization,
        'years_of_experience': yearsExperience,
        if (qualification != null) 'qualification': qualification,
        if (clinicName != null) 'clinic_name': clinicName,
        'clinic_address': clinicAddress ?? city,
        'languages': languages,
      };
}
