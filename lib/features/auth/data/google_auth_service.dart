import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/config/env_config.dart';

class GoogleAuthService {
  GoogleAuthService({GoogleSignIn? googleSignIn})
    : _googleSignIn =
          googleSignIn ??
          GoogleSignIn(
            clientId: kIsWeb
                ? (EnvConfig.googleClientIdWeb.isNotEmpty
                      ? EnvConfig.googleClientIdWeb
                      : null)
                : (!kIsWeb && (Platform.isIOS || Platform.isMacOS)
                      ? (EnvConfig.googleClientIdIos.isNotEmpty
                            ? EnvConfig.googleClientIdIos
                            : null)
                      : null),
            scopes: const ['email', 'profile'],
          );

  final GoogleSignIn _googleSignIn;

  /// Prompts user with native Google account picker dialog (choose Gmail)
  Future<GoogleSignInAccount?> signIn() async {
    return _googleSignIn.signIn();
  }

  /// Signs out from Google session
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore errors during local Google sign out
    }
  }
}

final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) {
  return GoogleAuthService();
});
