import 'package:flutter_test/flutter_test.dart';
import 'package:pun_account/core/network/api_client.dart';
import 'package:dio/dio.dart';

void main() {
  group('ApiClient with Dio', () {
    test('resolves default baseUrl', () {
      final client = ApiClient();
      expect(client.baseUrl, isNotEmpty);
      expect(client.baseUrl.endsWith('/api/v1'), isTrue);
    });

    test('sets and retains auth token', () {
      final client = ApiClient();
      client.setAuthToken('test-token-123');
      expect(client.authToken, equals('test-token-123'));
    });

    test('custom Dio instance and baseUrl can be injected', () {
      final dio = Dio();
      final client = ApiClient(baseUrl: 'http://custom-api:9000/v1', dio: dio);
      expect(client.baseUrl, equals('http://custom-api:9000/v1'));
      expect(client.dio, equals(dio));
    });
  });
}
