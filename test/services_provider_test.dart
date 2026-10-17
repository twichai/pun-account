import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pun_account/features/categories/domain/models/service_category_item.dart';
import 'package:pun_account/features/categories/presentation/providers/services_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

void main() {
  group('ServicesProvider Unit Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has default quick services and accounts', () {
      final state = container.read(servicesProvider);
      expect(state.quickServices.isNotEmpty, isTrue);
      expect(state.allAccounts.isNotEmpty, isTrue);
      expect(state.selectedFilterIndex, 0);
      expect(state.searchQuery, '');
      expect(state.filteredAccounts.length, state.allAccounts.length);
    });

    test('filtering by My Accounts returns only isMyAccount items', () {
      final notifier = container.read(servicesProvider.notifier);
      notifier.setFilterIndex(1);

      final state = container.read(servicesProvider);
      expect(state.selectedFilterIndex, 1);
      expect(state.filteredAccounts.every((item) => item.isMyAccount), isTrue);
    });

    test('search query filters accounts by name case-insensitively', () {
      final notifier = container.read(servicesProvider.notifier);
      notifier.setSearchQuery('openai');

      final state = container.read(servicesProvider);
      expect(state.filteredAccounts.length, 1);
      expect(state.filteredAccounts.first.name, contains('OpenAI'));
    });

    test('addService adds account properly', () {
      final notifier = container.read(servicesProvider.notifier);
      const newService = ServiceCategoryItem(
        id: 'test-999',
        name: 'New Test Service',
        accountNumber: 'Test 1234',
        icon: LucideIcons.cloud,
        color: Color(0xFF10B981),
        isMyAccount: true,
      );

      notifier.addService(newService, isQuickService: true);

      final state = container.read(servicesProvider);
      expect(state.quickServices.any((s) => s.id == 'test-999'), isTrue);
      expect(state.allAccounts.any((s) => s.id == 'test-999'), isTrue);
    });

    test('removeService removes account properly', () {
      final notifier = container.read(servicesProvider.notifier);
      final initialCount = container.read(servicesProvider).allAccounts.length;

      notifier.removeService('1');

      final state = container.read(servicesProvider);
      expect(state.allAccounts.length, initialCount - 1);
      expect(state.allAccounts.any((s) => s.id == '1'), isFalse);
    });
  });
}
