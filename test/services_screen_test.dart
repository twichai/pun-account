import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pun_account/features/categories/presentation/services_screen.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class TestServicesRepository implements ServicesRepository {
  @override
  Future<List<ServiceTrack>> getServiceCategories({
    String? businessId,
    String? search,
  }) async {
    return const [
      ServiceTrack(
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
            name: 'CapCut Pro',
            accountNumber: 'Chase 2983',
            icon: LucideIcons.video,
            color: Color(0xFF111827),
            serviceCategoryId: 'content_creator',
            categoryTrack: 'Content Creator',
            isMyAccount: true,
            isQuick: true,
          ),
        ],
      ),
      ServiceTrack(
        id: 'cat-2',
        key: 'developer',
        name: 'Developer',
        description: 'For devs',
        icon: LucideIcons.code,
        color: Color(0xFF10B981),
      ),
    ];
  }

  @override
  Future<ServiceTrack> getServiceCategoryById(
    String categoryId, {
    String? businessId,
    String? search,
  }) async {
    final list = await getServiceCategories(businessId: businessId, search: search);
    return list.first;
  }

  @override
  Future<List<ServiceCategoryItem>> getServices({
    String? businessId,
    String? categoryKey,
    String? search,
  }) async {
    final list = await getServiceCategories(businessId: businessId, search: search);
    return list.expand((t) => t.services).toList();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ServicesScreen Widget Tests', () {
    testWidgets('renders DraggableScrollableSheet, header, and quick services', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            servicesRepositoryProvider.overrideWithValue(TestServicesRepository()),
          ],
          child: const ShadcnApp(home: Scaffold(child: ServicesScreen())),
        ),
      );
      await tester.pumpAndSettle();

      // Verify DraggableScrollableSheet is present in the tree
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);

      // Verify Header & Recipients text
      expect(find.text('Recipients'), findsOneWidget);

      // Verify Add button is present
      expect(find.text('Add'), findsOneWidget);

      // Verify Content Creator Quick Services avatars are rendered
      expect(find.text('Canva Pro'), findsWidgets);
      expect(find.text('CapCut Pro'), findsWidgets);

      // Verify filter tabs in DraggableScrollableSheet
      expect(find.text('All'), findsOneWidget);
      expect(find.text('My accounts'), findsOneWidget);
    });
  });
}
