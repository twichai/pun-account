import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../domain/models/service_category_item.dart';
import '../../domain/models/service_track.dart';

export '../../domain/models/service_track.dart';

/// State representation for Services and Categories screen
class ServicesState {
  const ServicesState({
    this.tracks = defaultTracks,
    this.selectedTrackKey = 'content_creator',
    this.quickServices = defaultQuickServices,
    this.allAccounts = defaultAllAccounts,
    this.selectedFilterIndex = 0,
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
  });

  final List<ServiceTrack> tracks;
  final String selectedTrackKey; // 'content_creator', 'developer', 'designer', or 'all'
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
      items = items.where(
        (item) =>
            item.serviceCategoryId == null ||
            item.serviceCategoryId == selectedTrackKey,
      );
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
    return matched.isNotEmpty ? matched : quickServices;
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

  static const List<ServiceTrack> defaultTracks = [
    ServiceTrack(
      id: '01927600-0001-7000-8000-000000000001',
      key: 'content_creator',
      name: 'Content Creator',
      description: 'สำหรับยูทูบเบอร์, สตรีมเมอร์, คอนเทนต์ครีเอเตอร์, วิดีโอ และ AI tools',
      icon: LucideIcons.video,
      color: Color(0xFFEF4444),
    ),
    ServiceTrack(
      id: '01927600-0002-7000-8000-000000000002',
      key: 'developer',
      name: 'Developer',
      description: 'บริการคลาวด์ ซอฟต์แวร์ API และโค้ดดิ้งสำหรับนักพัฒนา',
      icon: LucideIcons.code,
      color: Color(0xFF10B981),
    ),
    ServiceTrack(
      id: '01927600-0003-7000-8000-000000000003',
      key: 'designer',
      name: 'Designer',
      description: 'เครื่องมือออกแบบ UI/UX, กราฟิก, ฟอนต์ และ asset design',
      icon: LucideIcons.palette,
      color: Color(0xFFA855F7),
    ),
  ];

  static const List<ServiceCategoryItem> defaultQuickServices = [
    // Content Creator Quick Services
    ServiceCategoryItem(
      id: '01927600-0101-7000-8000-000000000001',
      name: 'Canva Pro',
      accountNumber: 'KBank 1234',
      icon: LucideIcons.palette,
      color: Color(0xFF00C4CC),
      badge: 'Annual',
      imageUrl: 'https://avatars.githubusercontent.com/u/10639145?s=200&v=4',
      serviceCategoryId: 'content_creator',
      categoryTrack: 'Content Creator',
      isMyAccount: true,
      isQuick: true,
    ),
    ServiceCategoryItem(
      id: '01927600-0102-7000-8000-000000000002',
      name: 'Adobe Cloud',
      accountNumber: 'Mastercard 9283',
      icon: LucideIcons.palette,
      color: Color(0xFFED2224),
      badge: 'Monthly',
      imageUrl: 'https://avatars.githubusercontent.com/u/2232217?s=200&v=4',
      serviceCategoryId: 'content_creator',
      categoryTrack: 'Content Creator',
      isMyAccount: true,
      isQuick: true,
    ),
    ServiceCategoryItem(
      id: '01927600-0103-7000-8000-000000000003',
      name: 'CapCut Pro',
      accountNumber: 'Chase 2983',
      icon: LucideIcons.video,
      color: Color(0xFF111827),
      badge: 'Monthly',
      imageUrl: 'https://avatars.githubusercontent.com/u/5155369?s=200&v=4',
      serviceCategoryId: 'content_creator',
      categoryTrack: 'Content Creator',
      isMyAccount: true,
      isQuick: true,
    ),
    ServiceCategoryItem(
      id: '01927600-0104-7000-8000-000000000004',
      name: 'Midjourney',
      accountNumber: 'Chase 2983',
      icon: LucideIcons.sparkles,
      color: Color(0xFF18181B),
      badge: 'Monthly',
      imageUrl: 'https://avatars.githubusercontent.com/u/1342004?s=200&v=4',
      serviceCategoryId: 'content_creator',
      categoryTrack: 'Content Creator',
      isMyAccount: true,
      isQuick: true,
    ),
    ServiceCategoryItem(
      id: '01927600-0105-7000-8000-000000000001',
      name: 'ChatGPT Plus',
      accountNumber: 'Chase 2983',
      icon: LucideIcons.sparkles,
      color: Color(0xFF10B981),
      badge: 'Active',
      imageUrl: 'https://avatars.githubusercontent.com/u/14957082?s=200&v=4',
      serviceCategoryId: 'content_creator',
      categoryTrack: 'Content Creator',
      isMyAccount: true,
      isQuick: true,
    ),
    ServiceCategoryItem(
      id: '01927600-0106-7000-8000-000000000001',
      name: 'Epidemic Sound',
      accountNumber: 'KBank 1234',
      icon: LucideIcons.music,
      color: Color(0xFF1DB954),
      badge: 'Active',
      imageUrl: 'https://avatars.githubusercontent.com/u/9919?s=200&v=4',
      serviceCategoryId: 'content_creator',
      categoryTrack: 'Content Creator',
      isMyAccount: true,
      isQuick: true,
    ),

    // Developer Quick Services
    ServiceCategoryItem(
      id: '01927600-0201-7000-8000-000000000001',
      name: 'AWS Cloud',
      accountNumber: 'Mastercard 9283',
      icon: LucideIcons.cloud,
      color: Color(0xFFF59E0B),
      badge: 'Active',
      imageUrl: 'https://avatars.githubusercontent.com/u/2232217?s=200&v=4',
      serviceCategoryId: 'developer',
      categoryTrack: 'Developer',
      isMyAccount: true,
      isQuick: true,
    ),
    ServiceCategoryItem(
      id: '01927600-0202-7000-8000-000000000001',
      name: 'GitHub Copilot',
      accountNumber: 'Chase 2983',
      icon: LucideIcons.code,
      color: Color(0xFF6366F1),
      badge: 'Monthly',
      imageUrl: 'https://avatars.githubusercontent.com/u/9919?s=200&v=4',
      serviceCategoryId: 'developer',
      categoryTrack: 'Developer',
      isMyAccount: true,
      isQuick: true,
    ),

    // Designer Quick Services
    ServiceCategoryItem(
      id: '01927600-0301-7000-8000-000000000001',
      name: 'Figma',
      accountNumber: 'KBank 1234',
      icon: LucideIcons.palette,
      color: Color(0xFFA855F7),
      badge: 'Active',
      imageUrl: 'https://avatars.githubusercontent.com/u/5155369?s=200&v=4',
      serviceCategoryId: 'designer',
      categoryTrack: 'Designer',
      isMyAccount: true,
      isQuick: true,
    ),
  ];

  static const List<ServiceCategoryItem> defaultAllAccounts = [
    // Content Creator Accounts
    ServiceCategoryItem(
      id: '01927600-0101-7000-8000-000000000001',
      name: 'Canva Pro',
      accountNumber: 'KBank 1234',
      icon: LucideIcons.palette,
      color: Color(0xFF00C4CC),
      badge: 'Annual',
      imageUrl: 'https://avatars.githubusercontent.com/u/10639145?s=200&v=4',
      serviceCategoryId: 'content_creator',
      categoryTrack: 'Content Creator',
      isMyAccount: true,
    ),
    ServiceCategoryItem(
      id: '01927600-0102-7000-8000-000000000002',
      name: 'Adobe Creative Cloud',
      accountNumber: 'Mastercard 9283',
      icon: LucideIcons.palette,
      color: Color(0xFFED2224),
      badge: 'Monthly',
      imageUrl: 'https://avatars.githubusercontent.com/u/2232217?s=200&v=4',
      serviceCategoryId: 'content_creator',
      categoryTrack: 'Content Creator',
      isMyAccount: true,
    ),
    ServiceCategoryItem(
      id: '01927600-0103-7000-8000-000000000003',
      name: 'CapCut Pro',
      accountNumber: 'Chase 2983',
      icon: LucideIcons.video,
      color: Color(0xFF111827),
      badge: 'Monthly',
      imageUrl: 'https://avatars.githubusercontent.com/u/5155369?s=200&v=4',
      serviceCategoryId: 'content_creator',
      categoryTrack: 'Content Creator',
      isMyAccount: true,
    ),
    ServiceCategoryItem(
      id: '01927600-0104-7000-8000-000000000004',
      name: 'Midjourney AI',
      accountNumber: 'Chase 2983',
      icon: LucideIcons.sparkles,
      color: Color(0xFF18181B),
      badge: 'Monthly',
      imageUrl: 'https://avatars.githubusercontent.com/u/1342004?s=200&v=4',
      serviceCategoryId: 'content_creator',
      categoryTrack: 'Content Creator',
      isMyAccount: true,
    ),
    ServiceCategoryItem(
      id: '01927600-0105-7000-8000-000000000001',
      name: 'OpenAI ChatGPT Plus',
      accountNumber: 'Chase 2983',
      icon: LucideIcons.sparkles,
      color: Color(0xFF10B981),
      badge: 'Active',
      imageUrl: 'https://avatars.githubusercontent.com/u/14957082?s=200&v=4',
      serviceCategoryId: 'content_creator',
      categoryTrack: 'Content Creator',
      isMyAccount: true,
    ),
    ServiceCategoryItem(
      id: '01927600-0106-7000-8000-000000000001',
      name: 'Epidemic Sound (License)',
      accountNumber: 'KBank 1234',
      icon: LucideIcons.music,
      color: Color(0xFF1DB954),
      badge: 'Active',
      imageUrl: 'https://avatars.githubusercontent.com/u/9919?s=200&v=4',
      serviceCategoryId: 'content_creator',
      categoryTrack: 'Content Creator',
      isMyAccount: true,
    ),
    ServiceCategoryItem(
      id: '01927600-0107-7000-8000-000000000001',
      name: 'YouTube Premium',
      accountNumber: 'Mastercard 9283',
      icon: LucideIcons.play,
      color: Color(0xFFEF4444),
      badge: 'Monthly',
      serviceCategoryId: 'content_creator',
      categoryTrack: 'Content Creator',
      isMyAccount: false,
    ),
    ServiceCategoryItem(
      id: '01927600-0108-7000-8000-000000000001',
      name: 'Notion AI Workspace',
      accountNumber: 'Chase 2983',
      icon: LucideIcons.bookOpen,
      color: Color(0xFF09090B),
      badge: 'Active',
      serviceCategoryId: 'content_creator',
      categoryTrack: 'Content Creator',
      isMyAccount: true,
    ),

    // Developer Accounts
    ServiceCategoryItem(
      id: '01927600-0201-7000-8000-000000000001',
      name: 'AWS Infrastructure',
      accountNumber: 'Mastercard 9283',
      icon: LucideIcons.cloud,
      color: Color(0xFFF59E0B),
      badge: 'Active',
      imageUrl: 'https://avatars.githubusercontent.com/u/2232217?s=200&v=4',
      serviceCategoryId: 'developer',
      categoryTrack: 'Developer',
      isMyAccount: true,
    ),
    ServiceCategoryItem(
      id: '01927600-0202-7000-8000-000000000001',
      name: 'GitHub Copilot Enterprise',
      accountNumber: 'Chase 2983',
      icon: LucideIcons.code,
      color: Color(0xFF6366F1),
      badge: 'Monthly',
      imageUrl: 'https://avatars.githubusercontent.com/u/9919?s=200&v=4',
      serviceCategoryId: 'developer',
      categoryTrack: 'Developer',
      isMyAccount: true,
    ),
    ServiceCategoryItem(
      id: '01927600-0203-7000-8000-000000000001',
      name: 'Supabase Database',
      accountNumber: 'KBank 1234',
      icon: LucideIcons.database,
      color: Color(0xFF22C55E),
      badge: 'Active',
      imageUrl: 'https://avatars.githubusercontent.com/u/54469796?s=200&v=4',
      serviceCategoryId: 'developer',
      categoryTrack: 'Developer',
      isMyAccount: false,
    ),
    ServiceCategoryItem(
      id: '01927600-0204-7000-8000-000000000001',
      name: 'Vercel Pro',
      accountNumber: 'Chase 2983',
      icon: LucideIcons.triangle,
      color: Color(0xFF64748B),
      badge: 'Active',
      imageUrl: 'https://avatars.githubusercontent.com/u/14985020?s=200&v=4',
      serviceCategoryId: 'developer',
      categoryTrack: 'Developer',
      isMyAccount: false,
    ),

    // Designer Accounts
    ServiceCategoryItem(
      id: '01927600-0301-7000-8000-000000000001',
      name: 'Figma Enterprise',
      accountNumber: 'KBank 1234',
      icon: LucideIcons.palette,
      color: Color(0xFFA855F7),
      badge: 'Active',
      imageUrl: 'https://avatars.githubusercontent.com/u/5155369?s=200&v=4',
      serviceCategoryId: 'designer',
      categoryTrack: 'Designer',
      isMyAccount: true,
    ),
  ];
}

/// Notifier managing services, category recipients, and account filters
class ServicesNotifier extends Notifier<ServicesState> {
  @override
  ServicesState build() {
    return const ServicesState();
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
      state = state.copyWith(
        allAccounts: [...state.allAccounts, service],
      );
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
