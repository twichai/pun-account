# Flutter & shadcn_flutter Development Rules

This document outlines the coding standards, UI conventions, and architecture guidelines for the Flutter client in **Pun Account**.

---

## 🎨 UI & Design System (`shadcn_flutter`)

1. **Use `shadcn_flutter` as Primary Design System**:
   - Prefer `shadcn_flutter` widgets over standard Material or Cupertino widgets to preserve aesthetic consistency.
   - Root application must be configured with `ShadcnApp`:
     ```dart
     ShadcnApp(
       title: 'Pun Account',
       theme: ThemeData(
         colorScheme: ColorSchemes.lightSlate,
         radius: 0.5,
       ),
       darkTheme: ThemeData.dark(
         colorScheme: ColorSchemes.darkSlate,
       ),
       home: const HomeScreen(),
     )
     ```
2. **Colors & Theming**:
   - Avoid hardcoded Hex values in widget styles.
   - Use design tokens from `Theme.of(context).colorScheme` (e.g., `primary`, `secondary`, `muted`, `accent`, `border`, `destructive`).
   - For custom palette colors, access `Colors.<paletteName>[shade]` (e.g., `Colors.amber[500]`, `Colors.zinc[900]`).
3. **Typography**:
   - Use shadcn typography extensions directly on `Text` widgets (e.g., `Text('Title').h2()`, `Text('Caption').muted()`).
4. **Icons**:
   - Use consistent icon sets: `CupertinoIcons`, `lucide_icons`, or `radix_icons`. Avoid mixing disjointed icon styles.

---

## 🏗 Architecture & Code Structure

Organize Flutter code into clean, scalable layers under `lib/`:

```text
lib/
├── core/                # Shared utilities, theme configs, constants, HTTP client
│   ├── network/
│   ├── theme/
│   └── utils/
├── features/            # Feature-driven module architecture
│   ├── auth/
│   ├── dashboard/
│   ├── transactions/    # e.g., presentation/, controllers/, data/
│   ├── wallets/
│   └── settings/
└── main.dart            # Application bootstrap
```

### Layer Guidelines:
- **Presentation (`presentation/`)**:
  - Stateless widgets preferred; stateful only for transient local UI state (e.g. animation, local toggles).
  - Use `const` constructors aggressively.
  - Keep `build()` methods declarative and fast. Never invoke async network requests or DB queries directly inside `build()`.
- **State & Controller (`controllers/` or `providers/`)**:
  - Manage state using immutable objects.
  - Expose clear user intents / methods for UI event handling.
- **Data & Repository (`data/` / `repositories/`)**:
  - Handle communication with the Go backend API.
  - Map API DTOs into strongly typed models with proper error handling.

---

## 🧪 Quality & Code Health

1. **Linting & Analysis**:
   - Code must pass `flutter analyze` with 0 warnings or errors.
   - Follow standard Dart naming conventions: `lowerCamelCase` for variables and functions, `UpperCamelCase` for types/classes, `lowercase_with_underscores` for file names.
2. **Safety & Nullability**:
   - Embrace Dart null-safety strictly. Avoid `!` (force unwrap) unless logically impossible to be null.
   - Provide fallback states and graceful handling for network latency and empty views.
