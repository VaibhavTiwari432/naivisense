class ChildCreateRequest {
  final String fullName;
  final String? nickname;
  final String dob;
  final String gender;
  final List<String> diagnoses;
  final String severity;
  final List<String> therapyTargets;
  final String motherName;
  final String fatherName;
  final String contactNumber;
  final String city;
  final String? medicalNotes;

  const ChildCreateRequest({
    required this.fullName,
    this.nickname,
    required this.dob,
    required this.gender,
    required this.diagnoses,
    required this.severity,
    required this.therapyTargets,
    required this.motherName,
    required this.fatherName,
    required this.contactNumber,
    required this.city,
    this.medicalNotes,
  });

  Map<String, dynamic> toJson() => {
        'name': fullName,
        'date_of_birth': dob,
        'gender': gender,
        'diagnosis': diagnoses.join(', '),
        'therapy_goals': therapyTargets,
        if (medicalNotes != null) 'medical_notes': medicalNotes,
        'emergency_contact': {
          if (nickname != null) 'nickname': nickname,
          'severity': severity,
          'mother_name': motherName,
          'father_name': fatherName,
          'contact_number': contactNumber,
          'city': city,
        },
      };
}

class ChildUpdateRequest {
  final String? fullName;
  final String? nickname;
  final List<String>? diagnoses;
  final String? severity;
  final List<String>? therapyTargets;
  final String? city;
  final String? medicalNotes;
  final String? therapistId;

  const ChildUpdateRequest({
    this.fullName,
    this.nickname,
    this.diagnoses,
    this.severity,
    this.therapyTargets,
    this.city,
    this.medicalNotes,
    this.therapistId,
  });

  Map<String, dynamic> toJson() => {
        if (fullName != null) 'name': fullName,
        if (diagnoses != null) 'diagnosis': diagnoses!.join(', '),
        if (therapyTargets != null) 'therapy_goals': therapyTargets,
        if (medicalNotes != null) 'medical_notes': medicalNotes,
        if (therapistId != null) 'therapist_id': therapistId,
      };
}
