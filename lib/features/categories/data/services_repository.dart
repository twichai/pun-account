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
  Future<List<ServiceTrack>> getServiceCategories({String? businessId});
  Future<List<ServiceCategoryItem>> getServices({
    String? businessId,
    String? categoryKey,
  });
}

class ApiServicesRepository implements ServicesRepository {
  ApiServicesRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<List<ServiceTrack>> getServiceCategories({String? businessId}) async {
    final query = <String, dynamic>{};
    if (businessId != null && businessId.isNotEmpty) {
      query['business_id'] = businessId;
    }

    final response = await _client.get(
      '/services/categories',
      queryParameters: query,
    );

    if (response is List) {
      return response.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return ServiceTrack(
          id: map['id'] as String? ?? '',
          key: map['key'] as String? ?? '',
          name: map['name'] as String? ?? '',
          description: map['description'] as String? ?? '',
          icon: _mapIcon(map['icon'] as String?),
          color: _mapColor(map['color'] as String?),
        );
      }).toList();
    }
    throw const ApiException(
      statusCode: 500,
      message: 'Unexpected list service categories response format',
    );
  }

  @override
  Future<List<ServiceCategoryItem>> getServices({
    String? businessId,
    String? categoryKey,
  }) async {
    final query = <String, dynamic>{};
    if (businessId != null && businessId.isNotEmpty) {
      query['business_id'] = businessId;
    }
    if (categoryKey != null && categoryKey.isNotEmpty && categoryKey != 'all') {
      query['category'] = categoryKey;
    }

    final response = await _client.get(
      '/services/',
      queryParameters: query,
    );

    if (response is List) {
      return response.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        String? trackKey;
        String? trackName;
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
      }).toList();
    }
    throw const ApiException(
      statusCode: 500,
      message: 'Unexpected list services response format',
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
