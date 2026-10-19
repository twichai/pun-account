import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/animations/grid_wave_animation.dart';
import '../../transactions/presentation/send_request_modal.dart';
import '../domain/models/service_category_item.dart';
import 'providers/services_provider.dart';

export '../domain/models/service_category_item.dart';
export '../domain/models/service_track.dart';
export 'providers/services_provider.dart';

/// Services and Categories screen matching solopreneur and content creator workflows.
/// Fetches and displays job tracks (categories) and associated recurring services from the backend.
class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key, this.onAddCategory});

  final VoidCallback? onAddCategory;

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  bool _isSearching = false;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onPayService(ServiceCategoryItem service) {
    SendRequestModal.show(
      context,
      mode: TransferMode.send,
      recipientName: service.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final servicesState = ref.watch(servicesProvider);
    final tracks = servicesState.tracks;
    final selectedTrackKey = servicesState.selectedTrackKey;
    final quickServices = servicesState.trackQuickServices;
    final filteredAccounts = servicesState.filteredAccounts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Fixed Top Header: Recipients, Refresh trigger & "Add" button
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Recipients',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  if (servicesState.isLoading) ...[
                    const SizedBox(width: 12),
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton.ghost(
                    density: ButtonDensity.icon,
                    icon: const Icon(LucideIcons.refreshCw, size: 18),
                    onPressed: () {
                      ref
                          .read(servicesProvider.notifier)
                          .fetchCategoriesAndServices();
                    },
                  ),
                  // const SizedBox(width: 8),
                  // PrimaryButton(
                  //   onPressed: _showAddServiceModal,
                  //   child: const Text('Add'),
                  // ),
                ],
              ),
            ],
          ),
        ),

        // Main Body: Quick Services Grid behind + Draggable Bottom Sheet in front
        Expanded(
          child: Stack(
            children: [
              // 2x3 Grid of Circular Category / Service Avatars with Grid Wave animation
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = (constraints.maxWidth - 32) / 3;
                    const crossAxisCount = 3;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 24,
                      alignment: WrapAlignment.spaceAround,
                      children: [
                        if (quickServices.isEmpty && servicesState.isLoading)
                          for (int i = 0; i < 6; i++)
                            _buildSkeletonAvatar(itemWidth, isDark)
                        else
                          for (
                            int i = 0;
                            i < quickServices.length && i < 6;
                            i++
                          )
                            GridWaveAnimation.indexed(
                              index: i,
                              crossAxisCount: crossAxisCount,
                              child: _buildServiceAvatar(
                                quickServices[i],
                                itemWidth,
                              ),
                            ),
                      ],
                    );
                  },
                ),
              ),

              // Bottom Sheet: DraggableScrollableSheet
              // maxChildSize = 1.0 reaches exactly to the top of Expanded (right under the Header)
              DraggableScrollableSheet(
                initialChildSize: 0.60,
                minChildSize: 0.60,
                maxChildSize: 1.0,
                snap: true,
                snapSizes: const [0.60, 1.0],
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF18181B) : Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(scrollbars: false),
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
                        children: [
                          // Category filter tabs + Search button
                          Row(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  child: Row(
                                    children: [
                                      _buildFilterPill(
                                        title: 'All',
                                        isSelected: selectedTrackKey == 'all',
                                        onTap: () => ref
                                            .read(servicesProvider.notifier)
                                            .setTrack('all'),
                                        isDark: isDark,
                                      ),
                                      const SizedBox(width: 8),
                                      for (final track in tracks) ...[
                                        _buildFilterPill(
                                          title: track.name,
                                          isSelected:
                                              selectedTrackKey == track.key,
                                          onTap: () => ref
                                              .read(servicesProvider.notifier)
                                              .setTrack(track.key),
                                          isDark: isDark,
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton.ghost(
                                density: ButtonDensity.icon,
                                icon: Icon(
                                  _isSearching
                                      ? LucideIcons.x
                                      : LucideIcons.search,
                                  size: 18,
                                  color: isDark
                                      ? const Color(0xFFA1A1AA)
                                      : const Color(0xFF71717A),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isSearching = !_isSearching;
                                    if (!_isSearching) {
                                      _searchController.clear();
                                      ref
                                          .read(servicesProvider.notifier)
                                          .setSearchQuery('');
                                    }
                                  });
                                },
                              ),
                            ],
                          ),

                          if (_isSearching) ...[
                            const SizedBox(height: 12),
                            TextField(
                              controller: _searchController,
                              autofocus: true,
                              placeholder: const Text(
                                'Search recipients & accounts...',
                              ),
                              onChanged: (val) {
                                ref
                                    .read(servicesProvider.notifier)
                                    .setSearchQuery(val);
                              },
                            ),
                          ],

                          const SizedBox(height: 16),

                          // 3. List of services or clean empty state
                          if (filteredAccounts.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Center(
                                child: Text(
                                  'No services found for this category',
                                  style: TextStyle(
                                    color: isDark
                                        ? const Color(0xFFA1A1AA)
                                        : const Color(0xFF71717A),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                          else
                            for (
                              int index = 0;
                              index < filteredAccounts.length;
                              index++
                            ) ...[
                              if (index > 0) const SizedBox(height: 12),
                              _buildAccountTile(
                                filteredAccounts[index],
                                isDark,
                              ),
                            ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonAvatar(double width, bool isDark) {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 48,
            height: 12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
            ),
          ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }

  Widget _buildServiceAvatar(ServiceCategoryItem service, double width) {
    return GestureDetector(
      onTap: () => _onPayService(service),
      child: SizedBox(
        width: width,
        child: Column(
          children: [
            // Circular Avatar with Service Icon and status badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        service.color.withValues(alpha: 0.8),
                        service.color,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: service.color.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child:
                      service.imageUrl != null && service.imageUrl!.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: service.imageUrl!,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Icon(
                              service.icon,
                              size: 28,
                              color: Colors.white,
                            ),
                            errorWidget: (context, url, error) => Icon(
                              service.icon,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : service.simpleIconUrl != null
                          ? SvgPicture.network(
                              service.simpleIconUrl!,
                              width: 28,
                              height: 28,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                              placeholderBuilder: (context) => Icon(
                                service.icon,
                                size: 28,
                                color: Colors.white,
                              ),
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(service.icon, size: 28, color: Colors.white),
                            )
                          : Icon(service.icon, size: 28, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              service.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.white : const Color(0xFF09090B))
              : (isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? (isDark ? const Color(0xFF09090B) : Colors.white)
                : (isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A)),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTile(ServiceCategoryItem item, bool isDark) {
    return GestureDetector(
      onTap: () => _onPayService(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF27272A).withValues(alpha: 0.5)
              : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? const Color(0xFF3F3F46).withValues(alpha: 0.4)
                : const Color(0xFFF4F4F5),
          ),
        ),
        child: Row(
          children: [
            // Service Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.color.withValues(alpha: 0.18),
              ),
              alignment: Alignment.center,
              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Icon(item.icon, size: 20, color: item.color),
                        errorWidget: (context, url, error) =>
                            Icon(item.icon, size: 20, color: item.color),
                      ),
                    )
                  : item.simpleIconUrl != null
                      ? SvgPicture.network(
                          item.simpleIconUrl!,
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(
                            item.color,
                            BlendMode.srcIn,
                          ),
                          placeholderBuilder: (context) =>
                              Icon(item.icon, size: 20, color: item.color),
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(item.icon, size: 20, color: item.color),
                        )
                      : Icon(item.icon, size: 20, color: item.color),
            ),
            const SizedBox(width: 14),

            // Name & Account info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF09090B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.accountNumber,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF71717A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
