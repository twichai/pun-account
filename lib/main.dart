import 'package:shadcn_flutter/shadcn_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

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
        surfaceOpacity: 0.7,
      ),
      darkTheme: ThemeData.dark(
        colorScheme: ColorSchemes.darkSlate.yellow,
        radius: 0.75,
        surfaceOpacity: 0.7,
      ),
      themeMode: _themeMode,
      home: MyHomePage(
        title: 'Pun Account',
        themeMode: _themeMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.themeMode,
    required this.onToggleTheme,
  });

  final String title;
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      headers: [
        AppBar(
          title: Text(widget.title),
          trailing: [
            OutlineButton(
              density: ButtonDensity.icon,
              onPressed: widget.onToggleTheme,
              child: Icon(
                isDark ? LucideIcons.sun : LucideIcons.moon,
              ),
            ),
          ],
        ),
        const Divider(),
      ],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🐥 Welcome to Pun Account').h2(),
            const SizedBox(height: 8),
            Text(
              'Theme: ${isDark ? "Dark (Slate + Yellow)" : "Light (Slate + Yellow)"}',
            ).muted(),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('You have pushed the button this many times:'),
                    const SizedBox(height: 12),
                    Text('$_counter').h1(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PrimaryButton(
                          onPressed: _incrementCounter,
                          leading: const Icon(LucideIcons.plus),
                          child: const Text('Increment'),
                        ),
                        const SizedBox(width: 12),
                        OutlineButton(
                          onPressed: () {
                            setState(() {
                              _counter = 0;
                            });
                          },
                          leading: const Icon(LucideIcons.rotateCcw),
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
