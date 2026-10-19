import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'core/config/env_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/presentation/screens/sign_in_screen.dart';
import 'features/navigation/presentation/screens/main_navigation_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.home, this.overrides = const []});

  final Widget? home;
  final List<Override> overrides;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: PunApp(home: home),
    );
  }
}

class PunApp extends ConsumerWidget {
  const PunApp({super.key, this.home});

  final Widget? home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    final thaiTypography = Typography.geist(sans: GoogleFonts.notoSansThai());
    final themeData = ThemeData(
      colorScheme: ColorSchemes.lightSlate.yellow,
      radius: 0.75,
      typography: thaiTypography,
    );
    final darkThemeData = ThemeData.dark(
      colorScheme: ColorSchemes.darkSlate.yellow,
      radius: 0.75,
      typography: thaiTypography,
    );

    if (home != null) {
      return ShadcnApp(
        title: 'Pun Account',
        theme: themeData,
        darkTheme: darkThemeData,
        themeMode: themeMode,
        home: home,
      );
    }

    return ShadcnApp.router(
      title: 'Pun Account',
      theme: themeData,
      darkTheme: darkThemeData,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

/// Kept for backwards compatibility if referenced directly
class AuthGate extends ConsumerWidget {
  const AuthGate({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isAuthenticated) {
      return MainNavigationScreen(
        title: 'Pun Account',
        themeMode: themeMode,
        onToggleTheme: onToggleTheme,
      );
    }

    return SignInScreen(onToggleTheme: onToggleTheme);
  }
}
