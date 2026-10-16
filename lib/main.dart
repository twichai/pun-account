import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'features/navigation/presentation/screens/main_navigation_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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
    return ShadcnApp(
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
      home: MainNavigationScreen(
        title: 'Pun Account',
        themeMode: _themeMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}
