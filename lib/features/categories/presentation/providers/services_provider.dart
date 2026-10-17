import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services_repository.dart';
import '../../domain/models/service_category_item.dart';
import '../../domain/models/service_track.dart';

export '../../data/services_repository.dart';
export '../../domain/models/service_track.dart';

/// State representation for Services and Categories screen
class ServicesState {
  const ServicesState({
    this.tracks = const [],
    this.selectedTrackKey = 'content_creator',
    this.quickServices = const [],
    this.allAccounts = const [],
    this.selectedFilterIndex = 0,
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
  });

  final List<ServiceTrack> tracks;
  final String
  selectedTrackKey; // 'content_creator', 'developer', 'designer', or 'all'
  final List<ServiceCategoryItem> quickServices;
  final List<ServiceCategoryItem> allAccounts;
  final int selectedFilterIndex; // 0 = All, 1 = My accounts
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;

  /// Returns active track metadata
  ServiceTrack? get currentTrack {
    try {
      return tracks.firstWhere((t) => t.key == selectedTrackKey);
    } catch (_) {
      return null;
    }
  }

  /// Returns accounts filtered by track, tab (All vs My Accounts), and search query
  List<ServiceCategoryItem> get filteredAccounts {
    Iterable<ServiceCategoryItem> items = allAccounts;

    // Filter by track if a specific track is selected
    if (selectedTrackKey.isNotEmpty && selectedTrackKey != 'all') {
      items = items.where((item) => item.serviceCategoryId == selectedTrackKey);
    }

    // Filter by tab: 0 = All, 1 = My Accounts
    if (selectedFilterIndex == 1) {
      items = items.where((item) => item.isMyAccount);
    }

    // Filter by search query if non-empty
    if (searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      items = items.where(
        (item) =>
            item.name.toLowerCase().contains(query) ||
            item.accountNumber.toLowerCase().contains(query),
      );
    }

    return items.toList();
  }

  /// Returns quick services for the active track
  List<ServiceCategoryItem> get trackQuickServices {
    if (selectedTrackKey.isEmpty || selectedTrackKey == 'all') {
      return quickServices;
    }
    final matched = quickServices
        .where((s) => s.serviceCategoryId == selectedTrackKey)
        .toList();
    return matched;
  }

  ServicesState copyWith({
    List<ServiceTrack>? tracks,
    String? selectedTrackKey,
    List<ServiceCategoryItem>? quickServices,
    List<ServiceCategoryItem>? allAccounts,
    int? selectedFilterIndex,
    String? searchQuery,
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return ServicesState(
      tracks: tracks ?? this.tracks,
      selectedTrackKey: selectedTrackKey ?? this.selectedTrackKey,
      quickServices: quickServices ?? this.quickServices,
      allAccounts: allAccounts ?? this.allAccounts,
      selectedFilterIndex: selectedFilterIndex ?? this.selectedFilterIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

/// Notifier managing services, category recipients, and account filters using real backend API
class ServicesNotifier extends Notifier<ServicesState> {
  @override
  ServicesState build() {
    // Automatically trigger real API fetch on startup
    Future.microtask(() => fetchCategoriesAndServices());
    return const ServicesState(isLoading: true);
  }

  /// Fetch categories (tracks) with nested services from Go backend API
  Future<void> fetchCategoriesAndServices({
    String? businessId,
    String? search,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: () => null);
    try {
      final repo = ref.read(servicesRepositoryProvider);
      final categories = await repo.getServiceCategories(
        businessId: businessId,
        search: search,
      );

      // Extract all services nested inside categories
      final allServices = categories.expand((c) => c.services).toList();
      final quicks = allServices.where((s) => s.isQuick).toList();

      // Ensure active track key is valid
      String activeTrack = state.selectedTrackKey;
      if (categories.isNotEmpty &&
          !categories.any((t) => t.key == activeTrack) &&
          activeTrack != 'all') {
        activeTrack = categories.first.key;
      }

      state = state.copyWith(
        tracks: categories,
        allAccounts: allServices,
        quickServices: quicks,
        selectedTrackKey: activeTrack,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => e.toString(),
      );
    }
  }

  /// Change active job track (e.g. 'content_creator', 'developer', 'designer', or 'all')
  void setTrack(String trackKey) {
    state = state.copyWith(selectedTrackKey: trackKey);
  }

  /// Change active filter tab (0 = All, 1 = My Accounts)
  void setFilterIndex(int index) {
    state = state.copyWith(selectedFilterIndex: index);
  }

  /// Update search filter query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Add a service / recipient account
  void addService(ServiceCategoryItem service, {bool isQuickService = false}) {
    if (isQuickService) {
      state = state.copyWith(
        quickServices: [...state.quickServices, service],
        allAccounts: [...state.allAccounts, service],
      );
    } else {
      state = state.copyWith(allAccounts: [...state.allAccounts, service]);
    }
  }

  /// Remove a service / recipient account by id
  void removeService(String id) {
    state = state.copyWith(
      quickServices: state.quickServices.where((s) => s.id != id).toList(),
      allAccounts: state.allAccounts.where((s) => s.id != id).toList(),
    );
  }
}

final servicesProvider = NotifierProvider<ServicesNotifier, ServicesState>(() {
  return ServicesNotifier();
});
