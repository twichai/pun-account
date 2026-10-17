import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'core/config/env_config.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/presentation/screens/sign_in_screen.dart';
import 'features/navigation/presentation/screens/main_navigation_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.home});

  final Widget? home;

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
    return ProviderScope(
      child: ShadcnApp(
        title: 'Pun Account',
        theme: ThemeData(
          colorScheme: ColorSchemes.lightSlate.yellow,
          radius: 0.75,
        ),
        darkTheme: ThemeData.dark(
          colorScheme: ColorSchemes.darkSlate.yellow,
          radius: 0.75,
        ),
        themeMode: _themeMode,
        home: widget.home ??
            AuthGate(
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

    return SignInScreen(
      onToggleTheme: onToggleTheme,
    );
  }
}

