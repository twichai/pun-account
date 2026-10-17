import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../domain/models/service_category_item.dart';

/// State representation for Services and Categories screen
class ServicesState {
  const ServicesState({
    this.quickServices = defaultQuickServices,
    this.allAccounts = defaultAllAccounts,
    this.selectedFilterIndex = 0,
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
  });

  final List<ServiceCategoryItem> quickServices;
  final List<ServiceCategoryItem> allAccounts;
  final int selectedFilterIndex; // 0 = All, 1 = My accounts
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;

  /// Returns accounts filtered by selected tab (All vs My Accounts) and search query
  List<ServiceCategoryItem> get filteredAccounts {
    Iterable<ServiceCategoryItem> items = allAccounts;

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

  ServicesState copyWith({
    List<ServiceCategoryItem>? quickServices,
    List<ServiceCategoryItem>? allAccounts,
    int? selectedFilterIndex,
    String? searchQuery,
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return ServicesState(
      quickServices: quickServices ?? this.quickServices,
      allAccounts: allAccounts ?? this.allAccounts,
      selectedFilterIndex: selectedFilterIndex ?? this.selectedFilterIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  static const List<ServiceCategoryItem> defaultQuickServices = [
    ServiceCategoryItem(
      id: '1',
      name: 'OpenAI',
      accountNumber: 'Chase 2983',
      icon: LucideIcons.sparkles,
      color: Color(0xFF10B981),
      imageUrl: 'https://avatars.githubusercontent.com/u/14957082?s=200&v=4',
      isMyAccount: true,
    ),
    ServiceCategoryItem(
      id: '2',
      name: 'AWS Cloud',
      accountNumber: 'Mastercard 9283',
      icon: LucideIcons.cloud,
      color: Color(0xFFF59E0B),
      imageUrl: 'https://avatars.githubusercontent.com/u/2232217?s=200&v=4',
      isMyAccount: true,
    ),
    ServiceCategoryItem(
      id: '3',
      name: 'Figma',
      accountNumber: 'KBank 1234',
      icon: LucideIcons.palette,
      color: Color(0xFFA855F7),
      imageUrl: 'https://avatars.githubusercontent.com/u/5155369?s=200&v=4',
      isMyAccount: false,
    ),
    ServiceCategoryItem(
      id: '4',
      name: 'Apple',
      accountNumber: 'Chase 2983',
      icon: LucideIcons.laptop,
      color: Color(0xFF0EA5E9),
      imageUrl: 'https://avatars.githubusercontent.com/u/10639145?s=200&v=4',
      isMyAccount: true,
    ),
    ServiceCategoryItem(
      id: '5',
      name: 'Google Cloud',
      accountNumber: 'Mastercard 9283',
      icon: LucideIcons.globe,
      color: Color(0xFFEF4444),
      imageUrl: 'https://avatars.githubusercontent.com/u/1342004?s=200&v=4',
      isMyAccount: true,
    ),
    ServiceCategoryItem(
      id: '6',
      name: 'GitHub',
      accountNumber: 'Chase 2983',
      icon: LucideIcons.code,
      color: Color(0xFF6366F1),
      imageUrl: 'https://avatars.githubusercontent.com/u/9919?s=200&v=4',
      isMyAccount: true,
    ),
  ];

  static const List<ServiceCategoryItem> defaultAllAccounts = [
    ServiceCategoryItem(
      id: '1',
      name: 'OpenAI API & ChatGPT',
      accountNumber: 'Chase 2983',
      icon: LucideIcons.sparkles,
      color: Color(0xFF10B981),
      badge: 'Active',
      imageUrl: 'https://avatars.githubusercontent.com/u/14957082?s=200&v=4',
      isMyAccount: true,
    ),
    ServiceCategoryItem(
      id: '2',
      name: 'AWS Infrastructure',
      accountNumber: 'Mastercard 9283',
      icon: LucideIcons.cloud,
      color: Color(0xFFF59E0B),
      badge: 'Active',
      imageUrl: 'https://avatars.githubusercontent.com/u/2232217?s=200&v=4',
      isMyAccount: true,
    ),
    ServiceCategoryItem(
      id: '3',
      name: 'Figma Enterprise',
      accountNumber: 'KBank 1234',
      icon: LucideIcons.palette,
      color: Color(0xFFA855F7),
      badge: 'Active',
      imageUrl: 'https://avatars.githubusercontent.com/u/5155369?s=200&v=4',
      isMyAccount: false,
    ),
    ServiceCategoryItem(
      id: '4',
      name: 'Apple Developer Account',
      accountNumber: 'Chase 2983',
      icon: LucideIcons.laptop,
      color: Color(0xFF0EA5E9),
      badge: 'Annual',
      imageUrl: 'https://avatars.githubusercontent.com/u/10639145?s=200&v=4',
      isMyAccount: true,
    ),
    ServiceCategoryItem(
      id: '5',
      name: 'Supabase Database',
      accountNumber: 'KBank 1234',
      icon: LucideIcons.database,
      color: Color(0xFF22C55E),
      badge: 'Active',
      imageUrl: 'https://avatars.githubusercontent.com/u/54469796?s=200&v=4',
      isMyAccount: false,
    ),
    ServiceCategoryItem(
      id: '6',
      name: 'Vercel Pro',
      accountNumber: 'Chase 2983',
      icon: LucideIcons.triangle,
      color: Color(0xFF64748B),
      badge: 'Active',
      imageUrl: 'https://avatars.githubusercontent.com/u/14985020?s=200&v=4',
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
