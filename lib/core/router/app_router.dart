import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/business/presentation/business_screen.dart';
import '../../features/navigation/presentation/screens/main_navigation_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/transaction_details/transaction_details.dart';
import '../theme/theme_provider.dart';

export 'package:go_router/go_router.dart';

/// Centralized application route paths
abstract class AppRoutes {
  static const splash = '/splash';
  static const signIn = '/sign-in';
  static const home = '/';
  static const services = '/services';
  static const wallets = '/wallets';
  static const business = '/business';
  static const transactionDetails = '/transaction-details';
  static const transactionDetailsPattern = '/transaction-details/:walletId';

  static String transactionDetailsWithId(String walletId) =>
      '/transaction-details/$walletId';
}

/// RouterNotifier handles reactive routing based on authentication state
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authProvider,
      (previous, next) => notifyListeners(),
    );
  }

  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authProvider);
    final isInitial = authState.status == AuthStatus.initial;
    final isAuthenticated = authState.isAuthenticated;
    final matchedLocation = state.matchedLocation;

    // While session is restoring on app start:
    if (isInitial) {
      return matchedLocation == AppRoutes.splash ? null : AppRoutes.splash;
    }

    final isGoingToSplash = matchedLocation == AppRoutes.splash;
    final isGoingToSignIn = matchedLocation == AppRoutes.signIn;

    // When unauthenticated:
    if (!isAuthenticated) {
      return isGoingToSignIn ? null : AppRoutes.signIn;
    }

    // When authenticated: redirect away from splash or sign-in to home
    if (isGoingToSplash || isGoingToSignIn) {
      return AppRoutes.home;
    }

    return null;
  }
}

/// Creates a GoRouter instance for the app with all route definitions
GoRouter createAppRouter({
  String initialLocation = AppRoutes.splash,
  Widget? home,
  ThemeMode themeMode = ThemeMode.dark,
  VoidCallback? onToggleTheme,
  RouterNotifier? notifier,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: notifier,
    redirect: notifier?.redirect,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => Consumer(
          builder: (context, ref, child) {
            return SignInScreen(
              onToggleTheme: onToggleTheme ??
                  () => ref.read(themeModeProvider.notifier).toggle(),
            );
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) {
          if (home != null) return home;
          return Consumer(
            builder: (context, ref, child) {
              return MainNavigationScreen(
                title: 'Pun Account',
                initialTab: 1,
                themeMode: themeMode,
                onToggleTheme: onToggleTheme ??
                    () => ref.read(themeModeProvider.notifier).toggle(),
              );
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.services,
        builder: (context, state) => Consumer(
          builder: (context, ref, child) {
            return MainNavigationScreen(
              title: 'Pun Account',
              initialTab: 0,
              themeMode: themeMode,
              onToggleTheme: onToggleTheme ??
                  () => ref.read(themeModeProvider.notifier).toggle(),
            );
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.wallets,
        builder: (context, state) => Consumer(
          builder: (context, ref, child) {
            return MainNavigationScreen(
              title: 'Pun Account',
              initialTab: 2,
              themeMode: themeMode,
              onToggleTheme: onToggleTheme ??
                  () => ref.read(themeModeProvider.notifier).toggle(),
            );
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.business,
        builder: (context, state) => Consumer(
          builder: (context, ref, child) {
            return BusinessScreen(
              onToggleTheme: onToggleTheme ??
                  () => ref.read(themeModeProvider.notifier).toggle(),
            );
          },
        ),
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
    ],
  );
}

/// Riverpod provider for GoRouter instance
final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);
  return createAppRouter(notifier: notifier);
});
