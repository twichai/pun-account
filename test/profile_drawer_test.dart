import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pun_account/features/auth/controllers/auth_controller.dart';
import 'package:pun_account/features/auth/models/user_model.dart';
import 'package:pun_account/features/auth/presentation/widgets/profile_drawer.dart';
import 'package:pun_account/features/dashboard/presentation/widgets/overview_header.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class TestAuthNotifier extends AuthNotifier {
  final AuthState initialState;
  bool signOutCalled = false;

  TestAuthNotifier(this.initialState);

  @override
  AuthState build() => initialState;

  @override
  Future<void> signOut() async {
    signOutCalled = true;
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

void main() {
  const testUser = UserModel(
    id: 'user-12345678-uuid',
    email: 'sarah.design@studio.dev',
    name: 'Sarah Design',
    businessName: 'Studio Sarah',
  );
  const testSession = AuthSession(token: 'token-abc', user: testUser);

  testWidgets('Tapping avatar in OverviewHeader opens ProfileDrawer with user details', (
    tester,
  ) async {
    final notifier = TestAuthNotifier(
      const AuthState(status: AuthStatus.authenticated, session: testSession),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(() => notifier),
        ],
        child: const ShadcnApp(
          home: Scaffold(
            child: OverviewHeader(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify avatar initial 'S' is rendered
    expect(find.text('S'), findsOneWidget);

    // Tap on avatar
    await tester.tap(find.text('S'));
    await tester.pumpAndSettle();

    // Verify ProfileDrawer is displayed
    expect(find.byType(ProfileDrawer), findsOneWidget);
    expect(find.text('Account Profile'), findsOneWidget);
    expect(find.text('Sarah Design'), findsWidgets);
    expect(find.text('sarah.design@studio.dev'), findsOneWidget);
    expect(find.text('Studio Sarah'), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);
  });

  testWidgets('Tapping Log Out shows confirmation dialog, and confirming invokes signOut', (
    tester,
  ) async {
    final notifier = TestAuthNotifier(
      const AuthState(status: AuthStatus.authenticated, session: testSession),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(() => notifier),
        ],
        child: const ShadcnApp(
          home: Scaffold(
            child: OverviewHeader(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap on avatar to open drawer
    await tester.tap(find.text('S'));
    await tester.pumpAndSettle();

    // Tap "Log Out" button in drawer
    await tester.tap(find.text('Log Out'));
    await tester.pumpAndSettle();

    // Verify confirmation AlertDialog is shown
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.text('Are you sure you want to log out of your Pun Account on this device?'),
      findsOneWidget,
    );

    // Tap "Log Out" in the dialog
    final confirmButton = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(DestructiveButton, 'Log Out'),
    );
    expect(confirmButton, findsOneWidget);
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    // Verify signOut was called on notifier
    expect(notifier.signOutCalled, isTrue);

    // Drain toast duration timer
    await tester.pump(const Duration(seconds: 5));
  });
}
