import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/mock/mock_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/error_handler_service.dart';
import '../../../shared/models/child.dart';
import '../../../shared/models/session.dart';
import '../../../shared/models/therapist.dart';
import '../../../shared/models/user.dart';
import '../../../shared/models/api/auth_requests.dart';

final repositoryProvider =
    Provider<MockRepository>((ref) => MockRepository.instance);

// ── Auth state ──────────────────────────────────────────────────────────────

class AuthState {
  final UserRole? selectedRole;
  final AppUser? user;
  final bool isLoading;
  final String? error;
  final bool initialized;

  const AuthState({
    this.selectedRole,
    this.user,
    this.isLoading = false,
    this.error,
    this.initialized = false,
  });

  AuthState copyWith({
    UserRole? selectedRole,
    AppUser? user,
    bool clearUser = false,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? initialized,
  }) =>
      AuthState(
        selectedRole: selectedRole ?? this.selectedRole,
        user: clearUser ? null : (user ?? this.user),
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        initialized: initialized ?? this.initialized,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final MockRepository repo;
  final AuthRepository authRepo;

  AuthNotifier(this.repo, this.authRepo) : super(const AuthState());

  void selectRole(UserRole role) =>
      state = state.copyWith(selectedRole: role, clearError: true);

  Future<void> restoreSession() async {
    state = state.copyWith(isLoading: true);
    try {
      final hasSession = await authRepo.hasSession();
      if (hasSession) {
        final stored = await authRepo.getStoredUser();
        if (stored != null) {
          final user = AppUser(
            id: stored.id,
            name: stored.fullName,
            phone: stored.phone,
            email: stored.email,
            role: UserRole.values.firstWhere(
              (r) => r.name == stored.role,
              orElse: () => UserRole.parent,
            ),
          );
          state = state.copyWith(user: user, isLoading: false, initialized: true);
          return;
        }
      }
    } catch (_) {
      await authRepo.logout();
    }
    state = state.copyWith(isLoading: false, initialized: true);
  }

  // Real API login
  Future<void> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await authRepo.login(phone, password);
      final user = AppUser(
        id: response.user.id,
        name: response.user.fullName,
        phone: response.user.phone,
        email: response.user.email,
        role: UserRole.values.firstWhere(
          (r) => r.name == response.user.role,
          orElse: () => UserRole.parent,
        ),
      );
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ErrorHandlerService.handle(e).message,
      );
    }
  }

  // Real API register
  Future<void> register(RegisterRequest request) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await authRepo.register(request);
      final user = AppUser(
        id: response.user.id,
        name: response.user.fullName,
        phone: response.user.phone,
        email: response.user.email,
        role: UserRole.values.firstWhere(
          (r) => r.name == response.user.role,
          orElse: () => UserRole.parent,
        ),
      );
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ErrorHandlerService.handle(e).message,
      );
    }
  }

  // Demo/mock login for development (bypasses API)
  void loginWithMock() {
    final role = state.selectedRole ?? UserRole.therapist;
    state = state.copyWith(user: repo.userByRole(role));
  }

  Future<void> logout() async {
    await authRepo.logout();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(
    ref.read(repositoryProvider),
    ref.read(authRepositoryProvider),
  ),
);

// ── Children ──────────────────────────────────────────────────────────────

class ChildrenNotifier extends StateNotifier<List<Child>> {
  final MockRepository repo;
  ChildrenNotifier(this.repo) : super(repo.children);

  void add(Child c) {
    repo.addChild(c);
    state = List.of(repo.children);
  }

  void assign(String childId, List<String> therapistIds) {
    repo.assignTherapist(childId, therapistIds);
    state = List.of(repo.children);
  }
}

final childrenListProvider =
    StateNotifierProvider<ChildrenNotifier, List<Child>>(
  (ref) => ChildrenNotifier(ref.read(repositoryProvider)),
);

// ── Therapists ────────────────────────────────────────────────────────────

class TherapistsNotifier extends StateNotifier<List<Therapist>> {
  final MockRepository repo;
  TherapistsNotifier(this.repo) : super(repo.therapists);

  void add(Therapist t) {
    repo.addTherapist(t);
    state = List.of(repo.therapists);
  }
}

final therapistsListProvider =
    StateNotifierProvider<TherapistsNotifier, List<Therapist>>(
  (ref) => TherapistsNotifier(ref.read(repositoryProvider)),
);

// ── Tasks ─────────────────────────────────────────────────────────────────

class TasksNotifier extends StateNotifier<List<TherapyTask>> {
  final MockRepository repo;
  final String childId;
  TasksNotifier(this.repo, this.childId) : super(repo.tasksForChild(childId));

  void toggle(String taskId) {
    repo.toggleTask(taskId);
    state = repo.tasksForChild(childId);
  }
}

final tasksForChildProvider =
    StateNotifierProvider.family<TasksNotifier, List<TherapyTask>, String>(
  (ref, childId) => TasksNotifier(ref.read(repositoryProvider), childId),
);

// ── Sessions ──────────────────────────────────────────────────────────────

class SessionsNotifier extends StateNotifier<List<Session>> {
  final MockRepository repo;
  SessionsNotifier(this.repo) : super(repo.sessions);

  void update(Session s) {
    repo.updateSession(s);
    state = List.of(repo.sessions);
  }
}

final sessionsProvider =
    StateNotifierProvider<SessionsNotifier, List<Session>>(
  (ref) => SessionsNotifier(ref.read(repositoryProvider)),
);
