class SessionCreateRequest {
  final String childId;
  final String scheduledAt;
  final String sessionType;
  final int durationMinutes;
  final String? location;

  const SessionCreateRequest({
    required this.childId,
    required this.scheduledAt,
    required this.sessionType,
    required this.durationMinutes,
    this.location,
  });

  Map<String, dynamic> toJson() => {
        'child_id': childId,
        'scheduled_at': scheduledAt,
        'session_type': sessionType,
        'duration_minutes': durationMinutes,
        if (location != null) 'location': location,
      };
}

class SessionNotesRequest {
  final String mood;
  final int attention;
  final int communication;
  final int motorSkills;
  final int behavior;
  final List<String> activitiesDone;
  final String notes;
  final String? nextSessionPlan;

  const SessionNotesRequest({
    required this.mood,
    required this.attention,
    required this.communication,
    required this.motorSkills,
    required this.behavior,
    required this.activitiesDone,
    required this.notes,
    this.nextSessionPlan,
  });

  Map<String, dynamic> toJson() => {
        'attention_score': attention,
        'participation_score': communication,
        'mood_score': _moodScore(mood),
        'progress_score': motorSkills,
        'behavior_score': behavior,
        'observations': notes,
        'goals_worked_on': activitiesDone,
        if (nextSessionPlan != null) 'next_session_plan': nextSessionPlan,
      };

  int _moodScore(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return 5;
      case 'calm':
        return 3;
      case 'sad':
        return 1;
      default:
        return int.tryParse(mood) ?? 3;
    }
  }
}

class FeedbackCreateRequest {
  final String childId;
  final int sleepQuality;
  final int appetite;
  final int communication;
  final int meltdown;
  final String notes;
  final String? feedbackDate;
  final bool homePracticeDone;
  final int? moodScore;

  const FeedbackCreateRequest({
    required this.childId,
    required this.sleepQuality,
    required this.appetite,
    required this.communication,
    required this.meltdown,
    required this.notes,
    this.feedbackDate,
    this.homePracticeDone = false,
    this.moodScore,
  });

  Map<String, dynamic> toJson() => {
        'child_id': childId,
        if (feedbackDate != null) 'feedback_date': feedbackDate,
        'mood_score': moodScore ?? _moodFromMeltdown(meltdown),
        'sleep_score': sleepQuality,
        'appetite_score': appetite,
        'cooperation_score': communication,
        'home_practice_done': homePracticeDone,
        'notes': notes,
      };

  int _moodFromMeltdown(int meltdown) => (6 - meltdown).clamp(1, 5).toInt();
}
