import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'service_category_item.freezed.dart';

@freezed
abstract class ServiceCategoryItem with _$ServiceCategoryItem {
  const factory ServiceCategoryItem({
    required String id,
    required String name,
    required String accountNumber,
    required IconData icon,
    required Color color,
    String? badge,
    String? imageUrl,
    String? serviceCategoryId,
    String? categoryTrack,
    @Default(false) bool isMyAccount,
    @Default(false) bool isQuick,
  }) = _ServiceCategoryItem;
}
