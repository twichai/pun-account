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

    final rawIcon = map['icon'] as String? ?? '';
    final iconProvider = map['icon_provider'] as String? ?? 'simple-icons';

    return ServiceCategoryItem(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      accountNumber: map['account_number'] as String? ?? '',
      icon: _mapIcon(rawIcon),
      color: _mapColor(map['color'] as String?),
      badge: map['badge'] as String?,
      imageUrl: map['image_url'] as String?,
      serviceCategoryId: trackKey,
      categoryTrack: trackName,
      iconProvider: iconProvider,
      rawIcon: rawIcon,
      isQuick: map['is_quick'] as bool? ?? false,
      isMyAccount: true,
    );
  }

  static IconData _mapIcon(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'video':
      case 'runway':
      case 'kling':
      case 'capcut':
      case 'tiktok':
        return LucideIcons.video;
      case 'palette':
      case 'figma':
      case 'framer':
      case 'freepik':
      case 'icons8':
      case 'canva':
        return LucideIcons.palette;
      case 'sparkles':
      case 'openai':
      case 'chatgpt':
      case 'claude':
      case 'anthropic':
      case 'googlegemini':
      case 'gemini':
      case 'perplexity':
      case 'midjourney':
      case 'leonardo':
        return LucideIcons.sparkles;
      case 'music':
      case 'spotify':
      case 'applemusic':
      case 'youtubemusic':
      case 'epidemicsound':
      case 'artlist':
      case 'soundstripe':
      case 'elevenlabs':
        return LucideIcons.music;
      case 'code':
      case 'github':
      case 'gitlab':
      case 'npm':
      case 'sentry':
        return LucideIcons.code;
      case 'cloud':
      case 'googledrive':
      case 'googlecloud':
      case 'dropbox':
      case 'onedrive':
      case 'icloud':
      case 'cloudflare':
      case 'digitalocean':
      case 'aws':
        return LucideIcons.cloud;
      case 'laptop':
      case 'apple':
        return LucideIcons.laptop;
      case 'database':
      case 'neon':
      case 'supabase':
      case 'firebase':
        return LucideIcons.database;
      case 'triangle':
      case 'vercel':
        return LucideIcons.triangle;
      case 'layers':
      case 'envato':
      case 'docker':
        return LucideIcons.layers;
      case 'play':
      case 'play-circle':
      case 'youtube':
      case 'googleplay':
        return LucideIcons.play;
      case 'book-open':
      case 'oreilly':
        return LucideIcons.bookOpen;
      case 'shopping-bag':
      case 'shopping-cart':
      case 'store':
      case 'shopee':
      case 'lazada':
      case 'amazon':
      case 'gumroad':
        return LucideIcons.shoppingBag;
      case 'share-2':
      case 'share':
      case 'facebook':
      case 'instagram':
      case 'x':
      case 'linktree':
      case 'beacons':
        return LucideIcons.share2;
      case 'smartphone':
        return LucideIcons.smartphone;
      case 'graduation-cap':
      case 'udemy':
      case 'coursera':
      case 'skillshare':
      case 'pluralsight':
        return LucideIcons.graduationCap;
      case 'hard-drive':
      case 'backblaze':
        return LucideIcons.hardDrive;
      case 'server':
      case 'hostinger':
      case 'railway':
      case 'render':
        return LucideIcons.server;
      case 'camera':
        return LucideIcons.camera;
      case 'heart':
      case 'kofi':
        return LucideIcons.heart;
      case 'users':
      case 'patreon':
        return LucideIcons.users;
      case 'bot':
        return LucideIcons.bot;
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
