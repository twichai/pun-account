import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/network/api_client.dart';
import '../domain/models/service_category_item.dart';
import '../domain/models/service_track.dart';

/// Provider for ServicesRepository
final servicesRepositoryProvider = Provider<ServicesRepository>((ref) {
  return ApiServicesRepository(client: ref.watch(apiClientProvider));
});

abstract class ServicesRepository {
  Future<List<ServiceTrack>> getServiceCategories({
    String? businessId,
    String? search,
  });

  Future<ServiceTrack> getServiceCategoryById(
    String categoryId, {
    String? businessId,
    String? search,
  });

  Future<List<ServiceCategoryItem>> getServices({
    String? businessId,
    String? categoryKey,
    String? search,
  });
}

class ApiServicesRepository implements ServicesRepository {
  ApiServicesRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<List<ServiceTrack>> getServiceCategories({
    String? businessId,
    String? search,
  }) async {
    final query = <String, dynamic>{};
    if (businessId != null && businessId.isNotEmpty) {
      query['business_id'] = businessId;
    }
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }

    final response = await _client.get(
      '/services/categories',
      queryParameters: query,
    );

    if (response is List) {
      return response.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return _mapCategory(map);
      }).toList();
    }
    throw const ApiException(
      statusCode: 500,
      message: 'Unexpected list service categories response format',
    );
  }

  @override
  Future<ServiceTrack> getServiceCategoryById(
    String categoryId, {
    String? businessId,
    String? search,
  }) async {
    final query = <String, dynamic>{};
    if (businessId != null && businessId.isNotEmpty) {
      query['business_id'] = businessId;
    }
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }

    final response = await _client.get(
      '/services/categories/$categoryId',
      queryParameters: query,
    );

    if (response is Map) {
      return _mapCategory(Map<String, dynamic>.from(response));
    }
    throw const ApiException(
      statusCode: 500,
      message: 'Unexpected get service category response format',
    );
  }

  @override
  Future<List<ServiceCategoryItem>> getServices({
    String? businessId,
    String? categoryKey,
    String? search,
  }) async {
    final query = <String, dynamic>{};
    if (businessId != null && businessId.isNotEmpty) {
      query['business_id'] = businessId;
    }
    if (categoryKey != null && categoryKey.isNotEmpty && categoryKey != 'all') {
      query['category'] = categoryKey;
    }
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }

    final response = await _client.get('/services/', queryParameters: query);

    if (response is List) {
      return response.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return _mapServiceItem(map);
      }).toList();
    }
    throw const ApiException(
      statusCode: 500,
      message: 'Unexpected list services response format',
    );
  }

  ServiceTrack _mapCategory(Map<String, dynamic> map) {
    final categoryKey = map['key'] as String? ?? '';
    final categoryName = map['name'] as String? ?? '';

    List<ServiceCategoryItem> servicesList = const [];
    if (map['services'] is List) {
      servicesList = (map['services'] as List).map((s) {
        final serviceMap = Map<String, dynamic>.from(s as Map);
        return _mapServiceItem(
          serviceMap,
          fallbackCategoryKey: categoryKey,
          fallbackCategoryName: categoryName,
        );
      }).toList();
    }

    return ServiceTrack(
      id: map['id'] as String? ?? '',
      key: categoryKey,
      name: categoryName,
      description: map['description'] as String? ?? '',
      icon: _mapIcon(map['icon'] as String?),
      color: _mapColor(map['color'] as String?),
      services: servicesList,
    );
  }

  ServiceCategoryItem _mapServiceItem(
    Map<String, dynamic> map, {
    String? fallbackCategoryKey,
    String? fallbackCategoryName,
  }) {
    String? trackKey = fallbackCategoryKey;
    String? trackName = fallbackCategoryName;

    if (map['service_category'] is Map) {
      final cat = Map<String, dynamic>.from(map['service_category'] as Map);
      trackKey = cat['key'] as String?;
      trackName = cat['name'] as String?;
    }

    return ServiceCategoryItem(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      accountNumber: map['account_number'] as String? ?? '',
      icon: _mapIcon(map['icon'] as String?),
      color: _mapColor(map['color'] as String?),
      badge: map['badge'] as String?,
      imageUrl: map['image_url'] as String?,
      serviceCategoryId: trackKey,
      categoryTrack: trackName,
      isQuick: map['is_quick'] as bool? ?? false,
      isMyAccount: true,
    );
  }

  static IconData _mapIcon(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'video':
        return LucideIcons.video;
      case 'palette':
        return LucideIcons.palette;
      case 'sparkles':
        return LucideIcons.sparkles;
      case 'music':
        return LucideIcons.music;
      case 'code':
        return LucideIcons.code;
      case 'cloud':
        return LucideIcons.cloud;
      case 'laptop':
        return LucideIcons.laptop;
      case 'database':
        return LucideIcons.database;
      case 'triangle':
        return LucideIcons.triangle;
      case 'layers':
        return LucideIcons.layers;
      case 'play':
      case 'play-circle':
        return LucideIcons.play;
      case 'book-open':
        return LucideIcons.bookOpen;
      default:
        return LucideIcons.globe;
    }
  }

  static Color _mapColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return const Color(0xFF64748B);
    }
    final clean = hexColor.replaceAll('#', '');
    final intVal = int.tryParse(clean, radix: 16);
    if (intVal == null) return const Color(0xFF64748B);
    if (clean.length == 6) {
      return Color(0xFF000000 | intVal);
    }
    return Color(intVal);
  }
}
