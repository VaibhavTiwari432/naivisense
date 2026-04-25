class Child {
  final String id;
  final String fullName;
  final String? nickname;
  final DateTime dob;
  final String gender;
  final String? photoEmoji;
  final List<String> diagnoses;
  final String severity; // Mild / Moderate / High Support
  final List<String> therapyTargets;
  final String motherName;
  final String fatherName;
  final String contactNumber;
  final String city;
  final List<String> assignedTherapistIds;

  const Child({
    required this.id,
    required this.fullName,
    this.nickname,
    required this.dob,
    required this.gender,
    this.photoEmoji,
    required this.diagnoses,
    required this.severity,
    required this.therapyTargets,
    required this.motherName,
    required this.fatherName,
    required this.contactNumber,
    required this.city,
    this.assignedTherapistIds = const [],
  });

  int get ageInYears {
    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  factory Child.fromJson(Map<String, dynamic> json) {
    final emergencyContact = _mapOrEmpty(json['emergency_contact']);
    final therapistId = json['therapist_id']?.toString();

    return Child(
      id: json['id'] as String,
      fullName: (json['name'] ?? json['full_name']) as String,
      nickname: (json['nickname'] ?? emergencyContact['nickname']) as String?,
      dob: _dateFromJson(json['date_of_birth'] ?? json['dob']),
      gender: json['gender'] as String? ?? '',
      photoEmoji: json['photo_emoji'] as String?,
      diagnoses: _stringList(json['diagnoses'] ?? json['diagnosis']),
      severity:
          (json['severity'] ?? emergencyContact['severity'] ?? '').toString(),
      therapyTargets:
          _stringList(json['therapy_targets'] ?? json['therapy_goals']),
      motherName: (json['mother_name'] ?? emergencyContact['mother_name'] ?? '')
          .toString(),
      fatherName: (json['father_name'] ?? emergencyContact['father_name'] ?? '')
          .toString(),
      contactNumber:
          (json['contact_number'] ?? emergencyContact['contact_number'] ?? '')
              .toString(),
      city: (json['city'] ?? emergencyContact['city'] ?? '').toString(),
      assignedTherapistIds: therapistId == null || therapistId.isEmpty
          ? _stringList(json['assigned_therapist_ids'])
          : [therapistId],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': fullName,
        'date_of_birth': dob.toIso8601String().split('T').first,
        'gender': gender,
        'diagnosis': diagnoses.join(', '),
        'therapy_goals': therapyTargets,
        'emergency_contact': {
          if (nickname != null) 'nickname': nickname,
          'severity': severity,
          'mother_name': motherName,
          'father_name': fatherName,
          'contact_number': contactNumber,
          'city': city,
        },
        if (assignedTherapistIds.isNotEmpty)
          'therapist_id': assignedTherapistIds.first,
      };

  static Map<String, dynamic> _mapOrEmpty(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  static DateTime _dateFromJson(Object? value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  static List<String> _stringList(Object? value) {
    if (value is List) return value.map((item) => item.toString()).toList();
    if (value is String && value.isNotEmpty) {
      return value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const [];
  }

  Child copyWith({List<String>? assignedTherapistIds}) => Child(
        id: id,
        fullName: fullName,
        nickname: nickname,
        dob: dob,
        gender: gender,
        photoEmoji: photoEmoji,
        diagnoses: diagnoses,
        severity: severity,
        therapyTargets: therapyTargets,
        motherName: motherName,
        fatherName: fatherName,
        contactNumber: contactNumber,
        city: city,
        assignedTherapistIds: assignedTherapistIds ?? this.assignedTherapistIds,
      );
}
