class AppConstants {
  AppConstants._();
  static const String appName = 'NaiviSense';
  static const String tagline = 'Smarter Care for Every Child';
  static const String description =
      'A complete therapy platform for Therapists and Parents.';

  // API
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://naivisense-api.onrender.com/api/v1',
  );
  static const int connectionTimeoutMs = 30000;
  static const int sendTimeoutMs = 30000;
  static const int receiveTimeoutMs = 30000;

  // API endpoints
  static const String authRegisterEndpoint = '/auth/register';
  static const String authLoginEndpoint = '/auth/login';
  static const String authMeEndpoint = '/auth/me';
  static const String therapistProfileEndpoint = '/therapist/profile';
  static const String childrenEndpoint = '/children/';
  static const String sessionsEndpoint = '/sessions/';
  static const String upcomingSessionsEndpoint = '/sessions/upcoming';
  static const String feedbackDailyEndpoint = '/feedback/daily';
  static const String tasksEndpoint = '/tasks/';

  static String childEndpoint(String childId) => '/children/$childId';
  static String completeSessionEndpoint(String sessionId) =>
      '/sessions/$sessionId/complete';
  static String sessionNotesEndpoint(String sessionId) =>
      '/sessions/$sessionId/notes';
  static String feedbackHistoryEndpoint(String childId) =>
      '/feedback/history/$childId';
  static String progressReportEndpoint(String childId) =>
      '/reports/progress/$childId';
  static String taskEndpoint(String taskId) => '/tasks/$taskId';
  static const String adminCreateUserEndpoint = '/admin/create-user';

  // Secure storage keys
  static const String tokenKey = 'naivisense_auth_token';
  static const String tokenTypeKey = 'naivisense_token_type';
  static const String userKey = 'naivisense_user_data';
}

enum UserRole { admin, therapist, parent }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.therapist:
        return 'Therapist';
      case UserRole.parent:
        return 'Parent';
    }
  }
}
