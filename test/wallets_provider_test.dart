import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pun_account/features/auth/controllers/auth_controller.dart';
import 'package:pun_account/features/auth/models/user_model.dart';
import 'package:pun_account/features/wallets/data/wallets_repository.dart';
import 'package:pun_account/features/wallets/domain/models/wallet.dart';
import 'package:pun_account/features/wallets/domain/usecases/wallets_usecases.dart';
import 'package:pun_account/features/wallets/presentation/providers/wallets_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeWalletsRepository implements WalletsRepository {
  List<Wallet> items = [
    const Wallet(
      id: 'test-1',
      type: 'credit_card',
      balance: 10000.0,
      currency: 'THB',
      cardHolder: 'ORIGINAL',
      last4: '1111',
      cardBrand: 'visa',
      auroraAccent: 'cyan',
    ),
  ];

  @override
  Future<List<Wallet>> getWallets({required String businessId}) async {
    return items;
  }

  @override
  Future<Wallet> getWalletById(String id) async {
    return items.firstWhere((w) => w.id == id);
  }

  @override
  Future<Wallet> createWallet({
    required String businessId,
    required Wallet wallet,
    String? name,
  }) async {
    items = [...items, wallet];
    return wallet;
  }

  @override
  Future<Wallet> updateWallet({
    required String id,
    required Wallet wallet,
    String? name,
  }) async {
    items = items.map((w) => w.id == id ? wallet : w).toList();
    return wallet;
  }

  @override
  Future<void> deleteWallet(String id) async {
    items = items.where((w) => w.id != id).toList();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('WalletsNotifier Integration with UseCases', () {
    late FakeWalletsRepository fakeRepo;
    late ProviderContainer container;

    setUp(() {
      fakeRepo = FakeWalletsRepository();
      container = ProviderContainer(
        overrides: [
          walletsRepositoryProvider.overrideWithValue(fakeRepo),
          getWalletsUseCaseProvider.overrideWithValue(
            GetWalletsUseCase(fakeRepo),
          ),
          createWalletUseCaseProvider.overrideWithValue(
            CreateWalletUseCase(fakeRepo),
          ),
          updateWalletUseCaseProvider.overrideWithValue(
            UpdateWalletUseCase(fakeRepo),
          ),
          deleteWalletUseCaseProvider.overrideWithValue(
            DeleteWalletUseCase(fakeRepo),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has empty wallets and not loading', () {
      final state = container.read(walletsProvider);
      expect(state.isLoading, isFalse);
      expect(state.wallets, isEmpty);
      expect(state.errorMessage, isNull);
    });

    test('fetchWallets loads list from GetWalletsUseCase', () async {
      final notifier = container.read(walletsProvider.notifier);
      await notifier.fetchWallets();

      final state = container.read(walletsProvider);
      expect(state.isLoading, isFalse);
      expect(state.wallets.length, 1);
      expect(state.wallets.first.id, 'test-1');
    });

    test(
      'createWallet appends new wallet through CreateWalletUseCase',
      () async {
        final notifier = container.read(walletsProvider.notifier);
        const newCard = Wallet(
          id: 'new-2',
          type: 'credit_card',
          balance: 35000.0,
          currency: 'THB',
          cardHolder: 'ALICE',
          last4: '2222',
          cardBrand: 'mastercard',
          auroraAccent: 'violet',
        );

        final ok = await notifier.createWallet(newCard);
        expect(ok, isTrue);

        final state = container.read(walletsProvider);
        expect(state.wallets.any((w) => w.id == 'new-2'), isTrue);
      },
    );

    test(
      'updateWallet updates existing wallet through UpdateWalletUseCase',
      () async {
        final notifier = container.read(walletsProvider.notifier);
        await notifier.fetchWallets();

        final updated = fakeRepo.items.first.copyWith(
          cardHolder: 'UPDATED ALICE',
        );
        final ok = await notifier.updateWallet('test-1', updated);
        expect(ok, isTrue);

        final state = container.read(walletsProvider);
        expect(
          state.wallets.firstWhere((w) => w.id == 'test-1').cardHolder,
          'UPDATED ALICE',
        );
      },
    );

    test('deleteWallet removes wallet through DeleteWalletUseCase', () async {
      final notifier = container.read(walletsProvider.notifier);
      await notifier.fetchWallets();
      expect(container.read(walletsProvider).wallets.length, 1);

      final ok = await notifier.deleteWallet('test-1');
      expect(ok, isTrue);
      expect(container.read(walletsProvider).wallets, isEmpty);
    });

    test('WalletsNotifier fetches from API when user is authenticated with businessId', () async {
      final authContainer = ProviderContainer(
        overrides: [
          walletsRepositoryProvider.overrideWithValue(fakeRepo),
          getWalletsUseCaseProvider.overrideWithValue(
            GetWalletsUseCase(fakeRepo),
          ),
          createWalletUseCaseProvider.overrideWithValue(
            CreateWalletUseCase(fakeRepo),
          ),
          authProvider.overrideWith(
            () => _MockAuthNotifier(
              const AuthState(
                status: AuthStatus.authenticated,
                session: AuthSession(
                  token: 'mock-token',
                  user: UserModel(
                    id: 'user-1',
                    email: 'alex@indie.co',
                    name: 'Alex',
                    businessId: 'biz-123',
                  ),
                ),
              ),
            ),
          ),
        ],
      );
      addTearDown(authContainer.dispose);

      // Trigger read to mount WalletsNotifier with authenticated authProvider
      final state = authContainer.read(walletsProvider);
      expect(state.isLoading, isTrue);

      // Wait for microtask API fetch to complete
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final updatedState = authContainer.read(walletsProvider);
      expect(updatedState.isLoading, isFalse);
      expect(updatedState.wallets.length, 1);
      expect(updatedState.wallets.first.id, 'test-1');
    });
  });

  group('AuthNotifier Session Persistence Tests', () {
    test('restores saved session on startup', () async {
      SharedPreferences.setMockInitialValues({
        'pun_auth_session': '{"token":"persisted-jwt-123","user":{"id":"u-1","email":"user@test.com","name":"Test User","business_id":"biz-999"}}',
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initial unauthenticated before async microtask restore completes
      container.read(authProvider);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = container.read(authProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.session?.token, 'persisted-jwt-123');
      expect(state.session?.user.businessId, 'biz-999');
    });
  });
}

class _MockAuthNotifier extends AuthNotifier {
  _MockAuthNotifier(this._initialState);
  final AuthState _initialState;

  @override
  AuthState build() => _initialState;
}
