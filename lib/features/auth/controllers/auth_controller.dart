import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../data/google_auth_service.dart';
import '../models/user_model.dart';

enum AuthStatus {
  unauthenticated,
  authenticating,
  authenticated,
  error,
}

class AuthState {
  const AuthState({
    required this.status,
    this.session,
    this.errorMessage,
  });

  final AuthStatus status;
  final AuthSession? session;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated && session != null;
  bool get isLoading => status == AuthStatus.authenticating;

  AuthState copyWith({
    AuthStatus? status,
    AuthSession? session,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: session ?? this.session,
      errorMessage: errorMessage,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ApiAuthRepository();
});

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Real Google Account Picker (Native dialog allowing user to choose their Gmail)
  Future<bool> signInWithGoogleAccount() async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);

    try {
      final googleAuth = ref.read(googleAuthServiceProvider);
      final account = await googleAuth.signIn();

      if (account == null) {
        // User cancelled account selection popup
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return false;
      }

      final authTokens = await account.authentication;

      final repo = ref.read(authRepositoryProvider);
      final session = await repo.signInWithGoogle(
        idToken: authTokens.idToken,
        email: account.email,
        name: account.displayName,
        avatarUrl: account.photoUrl,
        googleId: account.id,
      );

      state = AuthState(
        status: AuthStatus.authenticated,
        session: session,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('ApiException: ', ''),
      );
      return false;
    }
  }

  Future<bool> signInWithGoogle({
    String? idToken,
    String? email,
    String? name,
    String? avatarUrl,
    String? googleId,
  }) async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);

    try {
      final repo = ref.read(authRepositoryProvider);
      final session = await repo.signInWithGoogle(
        idToken: idToken,
        email: email,
        name: name,
        avatarUrl: avatarUrl,
        googleId: googleId,
      );

      state = AuthState(
        status: AuthStatus.authenticated,
        session: session,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('ApiException: ', ''),
      );
      return false;
    }
  }

  Future<bool> signInDemo(String preset) async {
    if (preset == 'sarah') {
      return signInWithGoogle(
        email: 'sarah.design@studio.dev',
        name: 'Sarah Design',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        googleId: 'google-demo-sarah',
      );
    }

    // Default preset: Alex Solopreneur
    return signInWithGoogle(
      email: 'alex.maker@indie.co',
      name: 'Alex Maker',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      googleId: 'google-demo-alex',
    );
  }

  Future<void> signOut() async {
    try {
      await ref.read(googleAuthServiceProvider).signOut();
    } catch (_) {}
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
