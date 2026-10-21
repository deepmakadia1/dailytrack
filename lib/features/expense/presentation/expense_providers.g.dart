// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(transactionRepository)
final transactionRepositoryProvider = TransactionRepositoryProvider._();

final class TransactionRepositoryProvider
    extends
        $FunctionalProvider<
          TransactionRepository,
          TransactionRepository,
          TransactionRepository
        >
    with $Provider<TransactionRepository> {
  TransactionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionRepositoryHash();

  @$internal
  @override
  $ProviderElement<TransactionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TransactionRepository create(Ref ref) {
    return transactionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionRepository>(value),
    );
  }
}

String _$transactionRepositoryHash() =>
    r'884f6daf7b1fcc77f241972b6820439f53eb9118';

@ProviderFor(categoryRepository)
final categoryRepositoryProvider = CategoryRepositoryProvider._();

final class CategoryRepositoryProvider
    extends
        $FunctionalProvider<
          CategoryRepository,
          CategoryRepository,
          CategoryRepository
        >
    with $Provider<CategoryRepository> {
  CategoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<CategoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CategoryRepository create(Ref ref) {
    return categoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryRepository>(value),
    );
  }
}

String _$categoryRepositoryHash() =>
    r'e970a048906525c6eba810e216348d27c06d673e';

@ProviderFor(accountRepository)
final accountRepositoryProvider = AccountRepositoryProvider._();

final class AccountRepositoryProvider
    extends
        $FunctionalProvider<
          AccountRepository,
          AccountRepository,
          AccountRepository
        >
    with $Provider<AccountRepository> {
  AccountRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountRepositoryHash();

  @$internal
  @override
  $ProviderElement<AccountRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AccountRepository create(Ref ref) {
    return accountRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountRepository>(value),
    );
  }
}

String _$accountRepositoryHash() => r'2ade9fa3654d604df4c0d8d66ba7a25bd41044f8';

/// Budgets store (feature 003, T040).

@ProviderFor(budgetRepository)
final budgetRepositoryProvider = BudgetRepositoryProvider._();

/// Budgets store (feature 003, T040).

final class BudgetRepositoryProvider
    extends
        $FunctionalProvider<
          BudgetRepository,
          BudgetRepository,
          BudgetRepository
        >
    with $Provider<BudgetRepository> {
  /// Budgets store (feature 003, T040).
  BudgetRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetRepositoryHash();

  @$internal
  @override
  $ProviderElement<BudgetRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BudgetRepository create(Ref ref) {
    return budgetRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetRepository>(value),
    );
  }
}

String _$budgetRepositoryHash() => r'f1f2ea0ed6ef9f0553de868e45771a199a04b5df';

/// Sends budget alerts (feature 003 T057). Bound to the local notifier.
/// Named explicitly: the generator would drop the "Notifier" suffix.

@ProviderFor(budgetAlertNotifier)
final budgetAlertNotifierProvider = BudgetAlertNotifierProvider._();

/// Sends budget alerts (feature 003 T057). Bound to the local notifier.
/// Named explicitly: the generator would drop the "Notifier" suffix.

final class BudgetAlertNotifierProvider
    extends
        $FunctionalProvider<
          BudgetAlertNotifier,
          BudgetAlertNotifier,
          BudgetAlertNotifier
        >
    with $Provider<BudgetAlertNotifier> {
  /// Sends budget alerts (feature 003 T057). Bound to the local notifier.
  /// Named explicitly: the generator would drop the "Notifier" suffix.
  BudgetAlertNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetAlertNotifierProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetAlertNotifierHash();

  @$internal
  @override
  $ProviderElement<BudgetAlertNotifier> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BudgetAlertNotifier create(Ref ref) {
    return budgetAlertNotifier(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetAlertNotifier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetAlertNotifier>(value),
    );
  }
}

String _$budgetAlertNotifierHash() =>
    r'95f1826e3a2984b93916d6ebb8c765cbb915fb1c';

/// Settings and OS permission check for budget alerts (FR-018).

@ProviderFor(notificationGate)
final notificationGateProvider = NotificationGateProvider._();

/// Settings and OS permission check for budget alerts (FR-018).

final class NotificationGateProvider
    extends
        $FunctionalProvider<
          NotificationGate,
          NotificationGate,
          NotificationGate
        >
    with $Provider<NotificationGate> {
  /// Settings and OS permission check for budget alerts (FR-018).
  NotificationGateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationGateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationGateHash();

  @$internal
  @override
  $ProviderElement<NotificationGate> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NotificationGate create(Ref ref) {
    return notificationGate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationGate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationGate>(value),
    );
  }
}

String _$notificationGateHash() => r'396473a7f60fc74cbf2d3f0de81aeb0a70b09135';

/// The budget alert check run after each EXP-02 save (FR-015). Composed
/// from the bound repository, ports and clock; needs no binding itself.

@ProviderFor(budgetAlertChecker)
final budgetAlertCheckerProvider = BudgetAlertCheckerProvider._();

/// The budget alert check run after each EXP-02 save (FR-015). Composed
/// from the bound repository, ports and clock; needs no binding itself.

final class BudgetAlertCheckerProvider
    extends
        $FunctionalProvider<
          BudgetAlertChecker,
          BudgetAlertChecker,
          BudgetAlertChecker
        >
    with $Provider<BudgetAlertChecker> {
  /// The budget alert check run after each EXP-02 save (FR-015). Composed
  /// from the bound repository, ports and clock; needs no binding itself.
  BudgetAlertCheckerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetAlertCheckerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetAlertCheckerHash();

  @$internal
  @override
  $ProviderElement<BudgetAlertChecker> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BudgetAlertChecker create(Ref ref) {
    return budgetAlertChecker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetAlertChecker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetAlertChecker>(value),
    );
  }
}

String _$budgetAlertCheckerHash() =>
    r'01daa868d0db7610fd2fa3826b495cc406f21218';

/// Recurring rules store (feature 003, T075).

@ProviderFor(recurringRuleRepository)
final recurringRuleRepositoryProvider = RecurringRuleRepositoryProvider._();

/// Recurring rules store (feature 003, T075).

final class RecurringRuleRepositoryProvider
    extends
        $FunctionalProvider<
          RecurringRuleRepository,
          RecurringRuleRepository,
          RecurringRuleRepository
        >
    with $Provider<RecurringRuleRepository> {
  /// Recurring rules store (feature 003, T075).
  RecurringRuleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringRuleRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringRuleRepositoryHash();

  @$internal
  @override
  $ProviderElement<RecurringRuleRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecurringRuleRepository create(Ref ref) {
    return recurringRuleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecurringRuleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecurringRuleRepository>(value),
    );
  }
}

String _$recurringRuleRepositoryHash() =>
    r'9102b165c16bcc22260fe7823faa1e421116f7e5';

/// Creates due recurring entries on app open and from the daily job
/// (FR-023–FR-025). Composed from bound providers; needs no binding.

@ProviderFor(recurringGenerator)
final recurringGeneratorProvider = RecurringGeneratorProvider._();

/// Creates due recurring entries on app open and from the daily job
/// (FR-023–FR-025). Composed from bound providers; needs no binding.

final class RecurringGeneratorProvider
    extends
        $FunctionalProvider<
          RecurringGenerator,
          RecurringGenerator,
          RecurringGenerator
        >
    with $Provider<RecurringGenerator> {
  /// Creates due recurring entries on app open and from the daily job
  /// (FR-023–FR-025). Composed from bound providers; needs no binding.
  RecurringGeneratorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringGeneratorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringGeneratorHash();

  @$internal
  @override
  $ProviderElement<RecurringGenerator> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecurringGenerator create(Ref ref) {
    return recurringGenerator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecurringGenerator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecurringGenerator>(value),
    );
  }
}

String _$recurringGeneratorHash() =>
    r'8753c398fc9be8f003584269da10777c22bffa3c';

@ProviderFor(receiptPicker)
final receiptPickerProvider = ReceiptPickerProvider._();

final class ReceiptPickerProvider
    extends $FunctionalProvider<ReceiptPicker, ReceiptPicker, ReceiptPicker>
    with $Provider<ReceiptPicker> {
  ReceiptPickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'receiptPickerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$receiptPickerHash();

  @$internal
  @override
  $ProviderElement<ReceiptPicker> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReceiptPicker create(Ref ref) {
    return receiptPicker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReceiptPicker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReceiptPicker>(value),
    );
  }
}

String _$receiptPickerHash() => r'0d6bdd5f2c3d9e602e32f056e348ad3907ec5cc9';

@ProviderFor(receiptStore)
final receiptStoreProvider = ReceiptStoreProvider._();

final class ReceiptStoreProvider
    extends $FunctionalProvider<ReceiptStore, ReceiptStore, ReceiptStore>
    with $Provider<ReceiptStore> {
  ReceiptStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'receiptStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$receiptStoreHash();

  @$internal
  @override
  $ProviderElement<ReceiptStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReceiptStore create(Ref ref) {
    return receiptStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReceiptStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReceiptStore>(value),
    );
  }
}

String _$receiptStoreHash() => r'0cb50ee87133c90c51ad9146bb460489afb89444';

/// Translations of default names for the EXP-05 duplicate check (Q5). The
/// core implementation needs no binding; tests may override it.

@ProviderFor(defaultNameCatalog)
final defaultNameCatalogProvider = DefaultNameCatalogProvider._();

/// Translations of default names for the EXP-05 duplicate check (Q5). The
/// core implementation needs no binding; tests may override it.

final class DefaultNameCatalogProvider
    extends
        $FunctionalProvider<
          DefaultNameCatalog,
          DefaultNameCatalog,
          DefaultNameCatalog
        >
    with $Provider<DefaultNameCatalog> {
  /// Translations of default names for the EXP-05 duplicate check (Q5). The
  /// core implementation needs no binding; tests may override it.
  DefaultNameCatalogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'defaultNameCatalogProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$defaultNameCatalogHash();

  @$internal
  @override
  $ProviderElement<DefaultNameCatalog> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DefaultNameCatalog create(Ref ref) {
    return defaultNameCatalog(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DefaultNameCatalog value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DefaultNameCatalog>(value),
    );
  }
}

String _$defaultNameCatalogHash() =>
    r'de931c85a3c417f67909604a8714cd1bcd059737';
