import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/transaction_details/transaction_details.dart';
import '../../main.dart';

export 'package:go_router/go_router.dart';

/// Application Route paths
abstract class AppRoutes {
  static const home = '/';
  static const transactionDetails = '/transaction-details';
  static const transactionDetailsPattern = '/transaction-details/:walletId';
  static String transactionDetailsWithId(String walletId) =>
      '/transaction-details/$walletId';
  static const signIn = '/sign-in';
}

/// Creates a GoRouter instance for the app with all route definitions
GoRouter createAppRouter({
  String initialLocation = AppRoutes.home,
  Widget? home,
  ThemeMode themeMode = ThemeMode.dark,
  VoidCallback? onToggleTheme,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) {
          if (home != null) return home;
          return AuthGate(
            themeMode: themeMode,
            onToggleTheme: onToggleTheme ?? () {},
          );
        },
      ),
      GoRoute(
        path: AppRoutes.transactionDetailsPattern,
        builder: (context, state) {
          final walletId = state.pathParameters['walletId'];
          return TransactionDetailsPage(walletId: walletId);
        },
      ),
      GoRoute(
        path: AppRoutes.transactionDetails,
        builder: (context, state) {
          return const TransactionDetailsPage();
        },
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) =>
            SignInScreen(onToggleTheme: onToggleTheme ?? () {}),
      ),
    ],
  );
}

/// Riverpod provider for GoRouter instance
final appRouterProvider = Provider<GoRouter>((ref) {
  return createAppRouter();
});
