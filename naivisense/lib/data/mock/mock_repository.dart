import '../../core/constants/app_constants.dart';
import '../../shared/models/child.dart';
import '../../shared/models/session.dart';
import '../../shared/models/therapist.dart';
import '../../shared/models/user.dart';

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}

class MockRepository {
  MockRepository._internal();
  static final MockRepository instance = MockRepository._internal();

  // Users
  final List<AppUser> _users = const [
    AppUser(
      id: 'u_admin_1',
      name: 'Admin Head',
      phone: '+91 98000 00001',
      email: 'admin@naivisense.in',
      role: UserRole.admin,
      avatarEmoji: '🛡️',
    ),
    AppUser(
      id: 'u_therapist_1',
      name: 'Dr. Sharma',
      phone: '+91 98765 43210',
      email: 'sharma@naivisense.in',
      role: UserRole.therapist,
      avatarEmoji: '👨‍⚕️',
    ),
    AppUser(
      id: 'u_parent_1',
      name: 'Mrs. Priya Singh',
      phone: '+91 99123 45678',
      email: 'priya@example.com',
      role: UserRole.parent,
      avatarEmoji: '👩',
    ),
  ];

  AppUser userByRole(UserRole role) => _users.firstWhere((u) => u.role == role);

  // Therapists
  final List<Therapist> _therapists = [
    const Therapist(
      id: 't1',
      fullName: 'Dr. Ankit Sharma',
      phone: '+91 98765 43210',
      email: 'sharma@naivisense.in',
      specialization: 'Speech Therapy',
      yearsExperience: 8,
      city: 'Rajkot',
      avatarEmoji: '👨‍⚕️',
    ),
    const Therapist(
      id: 't2',
      fullName: 'Dr. Neha Verma',
      phone: '+91 98111 22222',
      email: 'neha@naivisense.in',
      specialization: 'Occupational Therapy',
      yearsExperience: 6,
      city: 'Ahmedabad',
      avatarEmoji: '👩‍⚕️',
    ),
    const Therapist(
      id: 't3',
      fullName: 'Riya Mehta',
      phone: '+91 98222 33333',
      email: 'riya@naivisense.in',
      specialization: 'Special Educator',
      yearsExperience: 4,
      city: 'Rajkot',
      avatarEmoji: '🧑‍🏫',
    ),
  ];

  List<Therapist> get therapists => List.unmodifiable(_therapists);
  Therapist? therapistById(String id) =>
      _therapists.where((t) => t.id == id).firstOrNull;
  void addTherapist(Therapist t) => _therapists.add(t);

  // Children
  final List<Child> _children = [
    Child(
      id: 'c1',
      fullName: 'Aarav Mehta',
      nickname: 'Aaru',
      dob: DateTime(2018, 5, 12),
      gender: 'Boy',
      photoEmoji: '👦',
      diagnoses: const ['Speech Delay'],
      severity: 'Moderate',
      therapyTargets: const ['Speech Therapy', 'Communication'],
      motherName: 'Priya Singh',
      fatherName: 'Rohit Mehta',
      contactNumber: '+91 99123 45678',
      city: 'Rajkot',
      assignedTherapistIds: const ['t1'],
    ),
    Child(
      id: 'c2',
      fullName: 'Kiara Patel',
      dob: DateTime(2019, 3, 8),
      gender: 'Girl',
      photoEmoji: '👧',
      diagnoses: const ['Occupational Delay'],
      severity: 'Mild',
      therapyTargets: const ['OT', 'Motor Skills'],
      motherName: 'Asha Patel',
      fatherName: 'Mehul Patel',
      contactNumber: '+91 97111 22233',
      city: 'Ahmedabad',
      assignedTherapistIds: const ['t2'],
    ),
    Child(
      id: 'c3',
      fullName: 'Vihaan Singh',
      dob: DateTime(2017, 10, 2),
      gender: 'Boy',
      photoEmoji: '🧒',
      diagnoses: const ['Autism'],
      severity: 'Moderate',
      therapyTargets: const ['Speech Therapy', 'Social Skills', 'Eye Contact'],
      motherName: 'Neha Singh',
      fatherName: 'Rajat Singh',
      contactNumber: '+91 97222 11111',
      city: 'Rajkot',
      assignedTherapistIds: const ['t1', 't3'],
    ),
  ];

  List<Child> get children => List.unmodifiable(_children);
  Child? childById(String id) => _children.where((c) => c.id == id).firstOrNull;
  void addChild(Child c) => _children.add(c);

  void assignTherapist(String childId, List<String> therapistIds) {
    final idx = _children.indexWhere((c) => c.id == childId);
    if (idx >= 0) {
      _children[idx] =
          _children[idx].copyWith(assignedTherapistIds: therapistIds);
    }
  }

  // Sessions
  late final List<Session> _sessions = _seedSessions();
  List<Session> _seedSessions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return [
      Session(
        id: 's1',
        childId: 'c1',
        therapistId: 't1',
        dateTime: today.add(const Duration(hours: 16)),
        type: 'Speech Therapy',
        durationMinutes: 45,
        status: SessionStatus.upcoming,
      ),
      Session(
        id: 's2',
        childId: 'c2',
        therapistId: 't2',
        dateTime: today.add(const Duration(hours: 17)),
        type: 'OT Session',
        durationMinutes: 45,
        status: SessionStatus.upcoming,
      ),
      Session(
        id: 's3',
        childId: 'c3',
        therapistId: 't1',
        dateTime: today.add(const Duration(hours: 18)),
        type: 'Follow Up',
        durationMinutes: 30,
        status: SessionStatus.upcoming,
      ),
      Session(
        id: 's4',
        childId: 'c1',
        therapistId: 't1',
        dateTime: today.subtract(const Duration(days: 2)),
        type: 'Speech Therapy',
        durationMinutes: 45,
        status: SessionStatus.completed,
        notes: const SessionNotes(
          mood: SessionMood.happy,
          attention: 4,
          communication: 4,
          motorSkills: 4,
          behavior: 3,
          activitiesDone: ['Ball Play', 'Sound Imitation'],
          notes: 'Aarav was engaged. Tried repeating words clearly.',
        ),
      ),
    ];
  }

  List<Session> get sessions => List.unmodifiable(_sessions);

  List<Session> sessionsForTherapistToday(String therapistId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _sessions
        .where((s) =>
            s.therapistId == therapistId &&
            DateTime(s.dateTime.year, s.dateTime.month, s.dateTime.day) == today)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<Session> sessionsForChild(String childId) =>
      _sessions.where((s) => s.childId == childId).toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

  Session? nextSessionForChild(String childId) {
    final now = DateTime.now();
    final upcoming = _sessions
        .where((s) => s.childId == childId && s.dateTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return upcoming.firstOrNull;
  }

  void updateSession(Session updated) {
    final idx = _sessions.indexWhere((s) => s.id == updated.id);
    if (idx >= 0) _sessions[idx] = updated;
  }

  // Tasks
  late final List<TherapyTask> _tasks = [
    TherapyTask(
      id: 'tk1',
      childId: 'c1',
      title: 'Practice Sounds: A, E, I, O, U',
      description: 'Repeat vowel sounds 10 times in the mirror.',
      assignedOn: DateTime.now(),
      completed: true,
    ),
    TherapyTask(
      id: 'tk2',
      childId: 'c1',
      title: 'Eye Contact Game - 5 Minutes',
      description: 'Play the stare-and-smile game.',
      assignedOn: DateTime.now(),
      completed: true,
    ),
    TherapyTask(
      id: 'tk3',
      childId: 'c1',
      title: 'Pencil Grip Practice Worksheet',
      description: 'Complete page 4 of the tracing book.',
      assignedOn: DateTime.now(),
    ),
    TherapyTask(
      id: 'tk4',
      childId: 'c1',
      title: 'Read Picture Book Together',
      description: '15 minutes of shared reading before bed.',
      assignedOn: DateTime.now(),
    ),
  ];

  List<TherapyTask> tasksForChild(String childId) =>
      _tasks.where((t) => t.childId == childId).toList();

  void toggleTask(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx >= 0) {
      _tasks[idx] = _tasks[idx].copyWith(completed: !_tasks[idx].completed);
    }
  }

  // Feedback
  final List<ParentFeedback> _feedbacks = [];
  List<ParentFeedback> feedbacksForChild(String childId) =>
      _feedbacks.where((f) => f.childId == childId).toList();
  void addFeedback(ParentFeedback f) => _feedbacks.add(f);

  // Reports
  ProgressReport reportForChild(String childId) {
    return ProgressReport(
      childId: childId,
      attendancePercent: 78,
      averageProgress: 4.2,
      sessionsCompleted: 12,
      speechTrend: const [
        WeeklyScore('Week 1', 3.1),
        WeeklyScore('Week 2', 3.4),
        WeeklyScore('Week 3', 3.8),
        WeeklyScore('Week 4', 4.2),
      ],
      therapistNote:
          'Aarav has shown great improvement in sound repetition and attention span. Keep practicing at home!',
    );
  }
}
