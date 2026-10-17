import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pun_account/features/categories/domain/models/service_category_item.dart';
import 'package:pun_account/features/categories/presentation/providers/services_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class FakeServicesRepository implements ServicesRepository {
  List<ServiceTrack> fakeTracks = [
    const ServiceTrack(
      id: 'cat-1',
      key: 'content_creator',
      name: 'Content Creator',
      description: 'For creators',
      icon: LucideIcons.video,
      color: Color(0xFFEF4444),
      services: [
        ServiceCategoryItem(
          id: 'svc-1',
          name: 'Canva Pro',
          accountNumber: 'KBank 1234',
          icon: LucideIcons.palette,
          color: Color(0xFF00C4CC),
          serviceCategoryId: 'content_creator',
          categoryTrack: 'Content Creator',
          isMyAccount: true,
          isQuick: true,
        ),
        ServiceCategoryItem(
          id: 'svc-2',
          name: 'ChatGPT Plus',
          accountNumber: 'Chase 2983',
          icon: LucideIcons.sparkles,
          color: Color(0xFF10B981),
          serviceCategoryId: 'content_creator',
          categoryTrack: 'Content Creator',
          isMyAccount: true,
          isQuick: true,
        ),
      ],
    ),
    const ServiceTrack(
      id: 'cat-2',
      key: 'developer',
      name: 'Developer',
      description: 'For devs',
      icon: LucideIcons.code,
      color: Color(0xFF10B981),
      services: [
        ServiceCategoryItem(
          id: 'svc-3',
          name: 'AWS Cloud',
          accountNumber: 'Mastercard 9283',
          icon: LucideIcons.cloud,
          color: Color(0xFFF59E0B),
          serviceCategoryId: 'developer',
          categoryTrack: 'Developer',
          isMyAccount: false,
          isQuick: true,
        ),
      ],
    ),
  ];

  @override
  Future<List<ServiceTrack>> getServiceCategories({
    String? businessId,
    String? search,
  }) async {
    if (search != null && search.isNotEmpty) {
      final query = search.toLowerCase();
      return fakeTracks
          .where((t) =>
              t.name.toLowerCase().contains(query) ||
              t.services.any((s) => s.name.toLowerCase().contains(query)))
          .toList();
    }
    return fakeTracks;
  }

  @override
  Future<ServiceTrack> getServiceCategoryById(
    String categoryId, {
    String? businessId,
    String? search,
  }) async {
    return fakeTracks.firstWhere(
      (t) => t.id == categoryId || t.key == categoryId,
    );
  }

  @override
  Future<List<ServiceCategoryItem>> getServices({
    String? businessId,
    String? categoryKey,
    String? search,
  }) async {
    var items = fakeTracks.expand((t) => t.services).toList();
    if (categoryKey != null && categoryKey.isNotEmpty && categoryKey != 'all') {
      items = items.where((s) => s.serviceCategoryId == categoryKey).toList();
    }
    if (search != null && search.isNotEmpty) {
      items = items.where((s) => s.name.toLowerCase().contains(search.toLowerCase())).toList();
    }
    return items;
  }
}

void main() {
  group('ServicesProvider Unit Tests', () {
    late ProviderContainer container;
    late FakeServicesRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeServicesRepository();
      container = ProviderContainer(
        overrides: [
          servicesRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('fetchCategoriesAndServices populates real data from repository with nested services', () async {
      await container
          .read(servicesProvider.notifier)
          .fetchCategoriesAndServices();

      final state = container.read(servicesProvider);
      expect(state.isLoading, isFalse);
      expect(state.tracks.length, 2);
      expect(state.allAccounts.length, 3);
      expect(state.selectedTrackKey, 'content_creator');
      expect(state.trackQuickServices.length, 2);
      expect(
        state.trackQuickServices
            .every((s) => s.serviceCategoryId == 'content_creator'),
        isTrue,
      );
    });

    test('switching track updates filtered accounts and quick services', () async {
      await container
          .read(servicesProvider.notifier)
          .fetchCategoriesAndServices();
      final notifier = container.read(servicesProvider.notifier);
      notifier.setTrack('developer');

      final state = container.read(servicesProvider);
      expect(state.selectedTrackKey, 'developer');
      expect(state.trackQuickServices.length, 1);
      expect(state.trackQuickServices.first.name, 'AWS Cloud');
      expect(state.filteredAccounts.length, 1);
      expect(state.filteredAccounts.first.name, 'AWS Cloud');
    });

    test('filtering by My Accounts returns only isMyAccount items', () async {
      await container
          .read(servicesProvider.notifier)
          .fetchCategoriesAndServices();
      final notifier = container.read(servicesProvider.notifier);
      notifier.setTrack('all');
      notifier.setFilterIndex(1);

      final state = container.read(servicesProvider);
      expect(state.selectedFilterIndex, 1);
      expect(state.filteredAccounts.every((item) => item.isMyAccount), isTrue);
      expect(state.filteredAccounts.length, 2); // Canva and ChatGPT
    });

    test('search query filters accounts by name case-insensitively', () async {
      await container
          .read(servicesProvider.notifier)
          .fetchCategoriesAndServices();
      final notifier = container.read(servicesProvider.notifier);
      notifier.setTrack('all');
      notifier.setSearchQuery('chatgpt');

      final state = container.read(servicesProvider);
      expect(state.filteredAccounts.length, 1);
      expect(state.filteredAccounts.first.name, contains('ChatGPT'));
    });

    test('addService adds account properly', () {
      final notifier = container.read(servicesProvider.notifier);
      const newService = ServiceCategoryItem(
        id: 'test-999',
        name: 'New Test Service',
        accountNumber: 'Test 1234',
        icon: LucideIcons.cloud,
        color: Color(0xFF10B981),
        serviceCategoryId: 'content_creator',
        isMyAccount: true,
      );

      notifier.addService(newService, isQuickService: true);

      final state = container.read(servicesProvider);
      expect(state.quickServices.any((s) => s.id == 'test-999'), isTrue);
      expect(state.allAccounts.any((s) => s.id == 'test-999'), isTrue);
    });

    test('removeService removes account properly', () async {
      await container
          .read(servicesProvider.notifier)
          .fetchCategoriesAndServices();
      final notifier = container.read(servicesProvider.notifier);
      final initialCount = container.read(servicesProvider).allAccounts.length;

      notifier.removeService('svc-1');

      final state = container.read(servicesProvider);
      expect(state.allAccounts.length, initialCount - 1);
      expect(state.allAccounts.any((s) => s.id == 'svc-1'), isFalse);
    });
  });
}
