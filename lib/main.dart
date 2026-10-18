import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'core/config/env_config.dart';
import 'core/router/app_router.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/presentation/screens/sign_in_screen.dart';
import 'features/navigation/presentation/screens/main_navigation_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.home, this.overrides = const []});

  final Widget? home;
  final List<Override> overrides;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.dark;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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

    return ProviderScope(
      overrides: widget.overrides,
      child: widget.home != null
          ? ShadcnApp(
              title: 'Pun Account',
              theme: themeData,
              darkTheme: darkThemeData,
              themeMode: _themeMode,
              home: widget.home,
            )
          : ShadcnApp.router(
              title: 'Pun Account',
              theme: themeData,
              darkTheme: darkThemeData,
              themeMode: _themeMode,
              routerConfig: createAppRouter(
                themeMode: _themeMode,
                onToggleTheme: _toggleTheme,
              ),
            ),
    );
  }
}

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
