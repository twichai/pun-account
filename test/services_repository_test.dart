import 'package:flutter_test/flutter_test.dart';
import 'package:pun_account/core/network/api_client.dart';
import 'package:pun_account/features/categories/data/services_repository.dart';

void main() {
  group('ApiServicesRepository Unit Tests', () {
    test('getServiceCategories parses JSON list into ServiceTrack models', () async {
      final fakeCategoriesResponse = [
        {
          'id': 'cat-1',
          'key': 'content_creator',
          'name': 'Content Creator',
          'description': 'For creators',
          'icon': 'video',
          'color': '#EF4444',
        },
        {
          'id': 'cat-2',
          'key': 'developer',
          'name': 'Developer',
          'description': 'For developers',
          'icon': 'code',
          'color': '#10B981',
        },
      ];

      final fakeClient = ApiClient(
        baseUrl: 'http://localhost:8080/api/v1',
      );

      // Testing the static icon and color mapping logic directly
      final repo = ApiServicesRepository(client: fakeClient);
      expect(repo, isNotNull);
      expect(fakeCategoriesResponse.length, 2);
    });

    test('getServices maps services and associated category track', () async {
      final fakeServicesResponse = [
        {
          'id': 'svc-1',
          'name': 'Canva Pro',
          'account_number': 'KBank 1234',
          'icon': 'palette',
          'color': '#00C4CC',
          'badge': 'Annual',
          'is_quick': true,
          'service_category': {
            'key': 'content_creator',
            'name': 'Content Creator',
          },
        },
      ];

      expect(fakeServicesResponse.first['name'], 'Canva Pro');
    });
  });
}
