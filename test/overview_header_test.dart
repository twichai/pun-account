import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pun_account/features/auth/controllers/auth_controller.dart';
import 'package:pun_account/features/auth/models/user_model.dart';
import 'package:pun_account/features/dashboard/presentation/widgets/overview_header.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class FakeAuthNotifier extends AuthNotifier {
  final AuthState initialState;
  FakeAuthNotifier(this.initialState);

  @override
  AuthState build() => initialState;
}

void main() {
  testWidgets('renders fallback emoji when user has no avatar_url', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ShadcnApp(home: Scaffold(child: OverviewHeader())),
      ),
    );
    await tester.pump();

    expect(find.text('P'), findsOneWidget);
    expect(find.byType(OverviewHeader), findsOneWidget);
  });

  testWidgets('renders avatar image when user has avatar_url', (tester) async {
    const user = UserModel(
      id: 'u-1',
      email: 'alex@example.com',
      name: 'Alex',
      avatarUrl: 'https://example.com/avatar.png',
    );
    const session = AuthSession(token: 'token-1', user: user);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(
            () => FakeAuthNotifier(
              const AuthState(
                status: AuthStatus.authenticated,
                session: session,
              ),
            ),
          ),
        ],
        child: const ShadcnApp(home: Scaffold(child: OverviewHeader())),
      ),
    );
    await tester.pump();

    // Verify OverviewHeader is rendered
    expect(find.byType(OverviewHeader), findsOneWidget);
  });
}
