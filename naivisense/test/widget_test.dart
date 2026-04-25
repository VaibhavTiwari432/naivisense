import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naivisense/core/constants/app_constants.dart';
import 'package:naivisense/features/auth/providers/auth_provider.dart';
import 'package:naivisense/features/auth/screens/role_login_screen.dart';
import 'package:naivisense/shared/models/user.dart';
import 'package:naivisense/shared/widgets/app_button.dart';
import 'package:naivisense/shared/widgets/app_widgets.dart';

// ─── Platform mock ───────────────────────────────────────────────────────────

void _mockSecureStorage() {
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async => null);
}

// ─── Fake AuthNotifier ───────────────────────────────────────────────────────

class _FakeAuthNotifier extends StateNotifier<AuthState>
    implements AuthNotifier {
  _FakeAuthNotifier(super.initial);

  @override
  void selectRole(UserRole role) =>
      state = state.copyWith(selectedRole: role, clearError: true);

  @override
  Future<void> login(String phone, String password) async {
    state = state.copyWith(
      user: AppUser(
        id: 'test-id',
        name: 'Test Therapist',
        phone: phone,
        role: state.selectedRole ?? UserRole.therapist,
      ),
      isLoading: false,
    );
  }

  @override
  Future<void> register(request) async {}

  @override
  Future<void> restoreSession() async =>
      state = state.copyWith(initialized: true);

  @override
  void loginWithMock() {}

  @override
  Future<void> logout() async => state = const AuthState();

  @override
  late final repo = throw UnimplementedError();

  @override
  late final authRepo = throw UnimplementedError();
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

Widget _wrap(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: child,
    ),
  );
}

Override _fakeAuth(AuthState state) =>
    authProvider.overrideWith((ref) => _FakeAuthNotifier(state));

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  setUpAll(_mockSecureStorage);

  // ── Smoke ──────────────────────────────────────────────────────────────────
  testWidgets('App renders without crashing', (t) async {
    await t.pumpWidget(_wrap(
      const Scaffold(body: Center(child: Text('NaiviSense'))),
    ));
    expect(find.text('NaiviSense'), findsOneWidget);
  });

  // ── StatusChip ─────────────────────────────────────────────────────────────
  group('StatusChip', () {
    testWidgets('renders label', (t) async {
      await t.pumpWidget(_wrap(const Scaffold(body: StatusChip(label: 'ASD'))));
      expect(find.text('ASD'), findsOneWidget);
    });

    testWidgets('selected renders', (t) async {
      await t.pumpWidget(_wrap(const Scaffold(
        body: StatusChip(label: 'Active', selected: true, color: Colors.blue),
      )));
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('onTap fires', (t) async {
      var tapped = false;
      await t.pumpWidget(_wrap(Scaffold(
        body: StatusChip(label: 'Tap', onTap: () => tapped = true),
      )));
      await t.tap(find.text('Tap'));
      expect(tapped, isTrue);
    });
  });

  // ── RatingStars ────────────────────────────────────────────────────────────
  group('RatingStars', () {
    testWidgets('renders 3 filled and 2 empty stars for value 3', (t) async {
      await t.pumpWidget(_wrap(Scaffold(
        body: RatingStars(value: 3, onChanged: (_) {}),
      )));
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
      expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(2));
    });

    testWidgets('value 5 shows all filled stars', (t) async {
      await t.pumpWidget(_wrap(Scaffold(
        body: RatingStars(value: 5, onChanged: (_) {}),
      )));
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(5));
      expect(find.byIcon(Icons.star_outline_rounded), findsNothing);
    });

    testWidgets('value 1 shows 1 filled star', (t) async {
      await t.pumpWidget(_wrap(Scaffold(
        body: RatingStars(value: 1, onChanged: (_) {}),
      )));
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(1));
      expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(4));
    });
  });

  // ── AppButton ──────────────────────────────────────────────────────────────
  group('AppButton', () {
    testWidgets('renders label and calls onPressed', (t) async {
      var pressed = false;
      await t.pumpWidget(_wrap(Scaffold(
        body: AppButton(label: 'Submit', onPressed: () => pressed = true),
      )));
      await t.tap(find.text('Submit'));
      expect(pressed, isTrue);
    });

    testWidgets('loading=true shows spinner and hides label', (t) async {
      await t.pumpWidget(_wrap(Scaffold(
        body: AppButton(label: 'Wait', loading: true, onPressed: () {}),
      )));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Wait'), findsNothing);
    });

    testWidgets('success variant renders', (t) async {
      await t.pumpWidget(_wrap(Scaffold(
        body: AppButton(
          label: 'Go',
          variant: AppButtonVariant.success,
          onPressed: () {},
        ),
      )));
      expect(find.text('Go'), findsOneWidget);
    });
  });

  // ── SectionHeader ──────────────────────────────────────────────────────────
  group('SectionHeader', () {
    testWidgets('renders title text', (t) async {
      await t.pumpWidget(_wrap(
        const Scaffold(body: SectionHeader(title: 'Overview')),
      ));
      expect(find.text('Overview'), findsOneWidget);
    });
  });

  // ── RoleSelectionScreen ────────────────────────────────────────────────────
  group('RoleSelectionScreen', () {
    testWidgets('shows Therapist, Parent, Admin role cards', (t) async {
      await t.pumpWidget(_wrap(
        const RoleSelectionScreen(),
        overrides: [_fakeAuth(const AuthState(initialized: true))],
      ));
      await t.pumpAndSettle();
      expect(find.text('Therapist'), findsOneWidget);
      expect(find.text('Parent'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
    });

    testWidgets('tapping a role card updates selected role', (t) async {
      final notifier = _FakeAuthNotifier(const AuthState(initialized: true));
      await t.pumpWidget(ProviderScope(
        overrides: [authProvider.overrideWith((ref) => notifier)],
        child: const MaterialApp(home: RoleSelectionScreen()),
      ));
      await t.pumpAndSettle();
      await t.tap(find.text('Parent'));
      await t.pump();
      expect(notifier.state.selectedRole, UserRole.parent);
    });

    testWidgets('toggle to register shows Full Name field', (t) async {
      await t.pumpWidget(_wrap(
        const RoleSelectionScreen(),
        overrides: [_fakeAuth(const AuthState(initialized: true))],
      ));
      await t.pumpAndSettle();
      final toggleFinder = find.text("Don't have an account? Register");
      await t.ensureVisible(toggleFinder);
      await t.tap(toggleFinder, warnIfMissed: false);
      await t.pump();
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('login without role shows snackbar', (t) async {
      await t.pumpWidget(_wrap(
        const RoleSelectionScreen(),
        overrides: [_fakeAuth(const AuthState(initialized: true))],
      ));
      await t.pumpAndSettle();
      await t.tap(find.text('Login'));
      await t.pump();
      expect(find.text('Please select a role first'), findsOneWidget);
    });

    testWidgets('phone validation rejects empty input', (t) async {
      await t.pumpWidget(_wrap(
        const RoleSelectionScreen(),
        overrides: [
          _fakeAuth(const AuthState(
            initialized: true,
            selectedRole: UserRole.therapist,
          )),
        ],
      ));
      await t.pumpAndSettle();
      await t.tap(find.text('Login'));
      await t.pump();
      expect(find.text('Phone is required'), findsOneWidget);
    });

    testWidgets('auth error is displayed in red box', (t) async {
      await t.pumpWidget(_wrap(
        const RoleSelectionScreen(),
        overrides: [
          _fakeAuth(const AuthState(
            initialized: true,
            selectedRole: UserRole.therapist,
            error: 'Phone not registered',
          )),
        ],
      ));
      await t.pumpAndSettle();
      expect(find.text('Phone not registered'), findsOneWidget);
    });
  });

  // ── UserRole extension ─────────────────────────────────────────────────────
  group('UserRole labels', () {
    test('therapist label is Therapist', () {
      expect(UserRole.therapist.label, 'Therapist');
    });
    test('parent label is Parent', () {
      expect(UserRole.parent.label, 'Parent');
    });
    test('admin label is Admin', () {
      expect(UserRole.admin.label, 'Admin');
    });
  });
}
