import '../../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  Future<AuthSession> signInWithGoogle({
    String? idToken,
    String? email,
    String? name,
    String? avatarUrl,
    String? googleId,
  });

  Future<AuthSession> getMe(String token);
}

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<AuthSession> signInWithGoogle({
    String? idToken,
    String? email,
    String? name,
    String? avatarUrl,
    String? googleId,
  }) async {
    final payload = <String, dynamic>{};
    if (idToken != null && idToken.isNotEmpty) {
      payload['id_token'] = idToken;
    }
    if (email != null && email.isNotEmpty) {
      payload['email'] = email;
    }
    if (name != null && name.isNotEmpty) {
      payload['name'] = name;
    }
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      payload['avatar_url'] = avatarUrl;
    }
    if (googleId != null && googleId.isNotEmpty) {
      payload['google_id'] = googleId;
    }

    final response = await _client.post('/auth/google', body: payload);
    if (response is Map) {
      final session = AuthSession.fromJson(Map<String, dynamic>.from(response));
      _client.setAuthToken(session.token);
      return session;
    }
    throw const ApiException(
      statusCode: 500,
      message: 'Unexpected auth response format',
    );
  }

  @override
  Future<AuthSession> getMe(String token) async {
    _client.setAuthToken(token);
    final response = await _client.get('/auth/me');
    if (response is Map) {
      return AuthSession.fromJson(Map<String, dynamic>.from(response));
    }
    throw const ApiException(
      statusCode: 500,
      message: 'Unexpected getMe response format',
    );
  }
}
