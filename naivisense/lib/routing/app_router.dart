import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/role_login_screen.dart';
import '../features/admin/screens/admin_screens.dart';
import '../features/admin/screens/add_child_screen.dart';
import '../features/therapist/screens/therapist_home.dart';
import '../features/therapist/screens/child_profile_screen.dart';
import '../features/therapist/screens/session_notes_screen.dart';
import '../features/parent/screens/parent_home.dart';
import '../features/parent/screens/parent_feedback_screen.dart';
import '../features/reports/screens/report_screens.dart';
import '../features/auth/providers/auth_provider.dart';
import '../core/constants/app_constants.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final path = state.uri.path;
      final isLoggedIn = authState.user != null;
      final isOnAuth = path == '/' || path == '/role';

      if (!isLoggedIn && !isOnAuth) return '/role';

      if (isLoggedIn && isOnAuth) {
        return _homeForRole(authState.user!.role);
      }

      if (isLoggedIn && !_canAccessPath(authState.user!.role, path)) {
        return _homeForRole(authState.user!.role);
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/role', builder: (_, __) => const RoleSelectionScreen()),

      // Admin
      GoRoute(path: '/admin', builder: (_, __) => const AdminDashboard()),
      GoRoute(
        path: '/admin/add-therapist',
        builder: (_, __) => const AddTherapistScreen(),
      ),
      GoRoute(
        path: '/admin/add-child',
        builder: (_, __) => const AddChildScreen(),
      ),
      GoRoute(
        path: '/admin/assign/:id',
        builder: (_, state) =>
            AssignTherapistScreen(childId: state.pathParameters['id']!),
      ),

      // Therapist
      GoRoute(path: '/therapist', builder: (_, __) => const TherapistHome()),
      GoRoute(
        path: '/therapist/child/:id',
        builder: (_, state) =>
            ChildProfileScreen(childId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/therapist/session/:id',
        builder: (_, state) =>
            SessionNotesScreen(sessionId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/therapist/report/:id',
        builder: (_, state) =>
            ProgressReportScreen(childId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/therapist/feedback/:id',
        builder: (_, state) =>
            WeeklyFeedbackScreen(childId: state.pathParameters['id']!),
      ),

      // Parent
      GoRoute(path: '/parent', builder: (_, __) => const ParentHome()),
      GoRoute(
        path: '/parent/feedback',
        builder: (_, __) => const ParentFeedbackScreen(),
      ),
      GoRoute(
        path: '/parent/report/:id',
        builder: (_, state) =>
            ProgressReportScreen(childId: state.pathParameters['id']!),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.uri}'),
      ),
    ),
  );
});

String _homeForRole(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return '/admin';
    case UserRole.therapist:
      return '/therapist';
    case UserRole.parent:
      return '/parent';
  }
}

bool _canAccessPath(UserRole role, String path) {
  switch (role) {
    case UserRole.admin:
      return path.startsWith('/admin');
    case UserRole.therapist:
      return path.startsWith('/therapist');
    case UserRole.parent:
      return path.startsWith('/parent');
  }
}
