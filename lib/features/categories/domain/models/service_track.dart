import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'service_category_item.dart';

part 'service_track.freezed.dart';

/// Represents a profession / business vertical track (เช่น Content Creator, Developer, Designer)
/// along with its associated services.
@freezed
abstract class ServiceTrack with _$ServiceTrack {
  const factory ServiceTrack({
    required String id,
    required String key,
    required String name,
    required String description,
    required IconData icon,
    required Color color,
    @Default([]) List<ServiceCategoryItem> services,
  }) = _ServiceTrack;
}
