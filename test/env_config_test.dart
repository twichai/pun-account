import 'package:flutter_test/flutter_test.dart';
import 'package:pun_account/core/config/env_config.dart';

void main() {
  group('EnvConfig', () {
    test('provides sensible defaults without crashing when .env file is missing', () async {
      await EnvConfig.init(fileName: '.env.nonexistent');

      expect(EnvConfig.appEnv, equals('development'));
      expect(EnvConfig.isDevelopment, isTrue);
      expect(EnvConfig.isProduction, isFalse);
      expect(EnvConfig.apiBaseUrl, isNotEmpty);
      expect(EnvConfig.apiTimeoutMs, greaterThan(0));
    });
  });
}
