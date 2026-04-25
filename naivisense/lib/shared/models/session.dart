enum SessionStatus { upcoming, completed, missed }

enum SessionMood { sad, calm, happy }

class Session {
  final String id;
  final String childId;
  final String therapistId;
  final DateTime dateTime;
  final String type;
  final int durationMinutes;
  final SessionStatus status;
  final SessionNotes? notes;

  const Session({
    required this.id,
    required this.childId,
    required this.therapistId,
    required this.dateTime,
    required this.type,
    required this.durationMinutes,
    required this.status,
    this.notes,
  });

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        id: json['id'] as String,
        childId: json['child_id'] as String,
        therapistId: json['therapist_id'] as String,
        dateTime: DateTime.parse(json['scheduled_at'] as String),
        type: json['session_type'] as String? ?? 'General',
        durationMinutes: json['duration_minutes'] as int? ?? 60,
        status: _statusFromString(json['status'] as String? ?? 'upcoming'),
        notes: json['notes'] == null
            ? null
            : SessionNotes.fromJson(json['notes'] as Map<String, dynamic>),
      );

  static SessionStatus _statusFromString(String s) {
    switch (s.toLowerCase()) {
      case 'scheduled':
      case 'in_progress':
      case 'upcoming':
        return SessionStatus.upcoming;
      case 'completed':
        return SessionStatus.completed;
      case 'cancelled':
      case 'missed':
        return SessionStatus.missed;
      default:
        return SessionStatus.upcoming;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'child_id': childId,
        'therapist_id': therapistId,
        'scheduled_at': dateTime.toIso8601String(),
        'session_type': type,
        'duration_minutes': durationMinutes,
        'status': status.name,
      };

  Session copyWith({SessionStatus? status, SessionNotes? notes}) => Session(
        id: id,
        childId: childId,
        therapistId: therapistId,
        dateTime: dateTime,
        type: type,
        durationMinutes: durationMinutes,
        status: status ?? this.status,
        notes: notes ?? this.notes,
      );
}

class SessionNotes {
  final SessionMood mood;
  final int attention;
  final int communication;
  final int motorSkills;
  final int behavior;
  final List<String> activitiesDone;
  final String notes;

  const SessionNotes({
    required this.mood,
    required this.attention,
    required this.communication,
    required this.motorSkills,
    required this.behavior,
    required this.activitiesDone,
    required this.notes,
  });

  factory SessionNotes.fromJson(Map<String, dynamic> json) => SessionNotes(
        mood: _moodFromScore(json['mood_score']),
        attention: json['attention_score'] as int? ?? 0,
        communication: json['participation_score'] as int? ?? 0,
        motorSkills: json['progress_score'] as int? ?? 0,
        behavior: json['behavior_score'] as int? ?? 0,
        activitiesDone:
            List<String>.from(json['goals_worked_on'] as List? ?? []),
        notes: json['observations'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'mood_score': _scoreFromMood(mood),
        'attention_score': attention,
        'participation_score': communication,
        'progress_score': motorSkills,
        'behavior_score': behavior,
        'goals_worked_on': activitiesDone,
        'observations': notes,
      };

  static SessionMood _moodFromScore(Object? value) {
    final score = value is int ? value : int.tryParse(value?.toString() ?? '');
    if (score == null) return SessionMood.calm;
    if (score <= 2) return SessionMood.sad;
    if (score >= 4) return SessionMood.happy;
    return SessionMood.calm;
  }

  static int _scoreFromMood(SessionMood mood) {
    switch (mood) {
      case SessionMood.sad:
        return 1;
      case SessionMood.calm:
        return 3;
      case SessionMood.happy:
        return 5;
    }
  }
}

class TherapyTask {
  final String id;
  final String childId;
  final String title;
  final String description;
  final DateTime assignedOn;
  final bool completed;
  final String status;

  const TherapyTask({
    required this.id,
    required this.childId,
    required this.title,
    required this.description,
    required this.assignedOn,
    this.completed = false,
    this.status = 'pending',
  });

  factory TherapyTask.fromJson(Map<String, dynamic> json) => TherapyTask(
        id: json['id'] as String,
        childId: json['child_id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        assignedOn: DateTime.parse(json['created_at'] as String),
        status: json['status'] as String? ?? 'pending',
        completed: (json['status'] as String?) == 'completed',
      );

  TherapyTask copyWith({bool? completed}) => TherapyTask(
        id: id,
        childId: childId,
        title: title,
        description: description,
        assignedOn: assignedOn,
        completed: completed ?? this.completed,
        status: status,
      );
}

class ParentFeedback {
  final String id;
  final String childId;
  final DateTime date;
  final int sleepQuality;
  final int appetite;
  final int communication;
  final int meltdown;
  final String notes;

  const ParentFeedback({
    required this.id,
    required this.childId,
    required this.date,
    required this.sleepQuality,
    required this.appetite,
    required this.communication,
    required this.meltdown,
    required this.notes,
  });

  factory ParentFeedback.fromJson(Map<String, dynamic> json) => ParentFeedback(
        id: json['id'] as String,
        childId: json['child_id'] as String,
        date: DateTime.parse(
          (json['feedback_date'] ?? json['date']) as String,
        ),
        sleepQuality:
            json['sleep_score'] as int? ?? json['sleep_quality'] as int? ?? 0,
        appetite:
            json['appetite_score'] as int? ?? json['appetite'] as int? ?? 0,
        communication: json['cooperation_score'] as int? ??
            json['communication'] as int? ??
            0,
        meltdown: json['meltdown'] as int? ??
            _meltdownFromMood(json['mood_score']) ??
            0,
        notes: json['notes'] as String? ?? '',
      );

  static int? _meltdownFromMood(Object? value) {
    final score = value is int ? value : int.tryParse(value?.toString() ?? '');
    if (score == null) return null;
    return (6 - score).clamp(1, 5).toInt();
  }
}

class WeeklyScore {
  final String label;
  final double score;
  const WeeklyScore(this.label, this.score);
}

class ProgressReport {
  final String childId;
  final int attendancePercent;
  final double averageProgress;
  final int sessionsCompleted;
  final List<WeeklyScore> speechTrend;
  final String therapistNote;

  const ProgressReport({
    required this.childId,
    required this.attendancePercent,
    required this.averageProgress,
    required this.sessionsCompleted,
    required this.speechTrend,
    required this.therapistNote,
  });

  factory ProgressReport.fromJson(Map<String, dynamic> json) => ProgressReport(
        childId: json['child_id'] as String,
        attendancePercent: json['attendance_percent'] as int? ?? 0,
        averageProgress: (json['average_progress'] as num?)?.toDouble() ?? 0.0,
        sessionsCompleted: json['sessions_completed'] as int? ?? 0,
        speechTrend: ((json['progress_trend'] as List?) ?? [])
            .map((t) => WeeklyScore(
                  t['label'] as String,
                  (t['score'] as num).toDouble(),
                ))
            .toList(),
        therapistNote:
            json['therapist_note'] as String? ?? 'No therapist notes yet.',
      );
}
