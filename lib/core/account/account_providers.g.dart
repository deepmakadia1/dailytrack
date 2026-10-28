// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Google sign-in (feature 010 research R1). `production_overrides.dart`
/// binds `GoogleAuth`; tests bind `FakeAccountAuth`.

@ProviderFor(accountAuth)
final accountAuthProvider = AccountAuthProvider._();

/// Google sign-in (feature 010 research R1). `production_overrides.dart`
/// binds `GoogleAuth`; tests bind `FakeAccountAuth`.

final class AccountAuthProvider
    extends $FunctionalProvider<AccountAuth, AccountAuth, AccountAuth>
    with $Provider<AccountAuth> {
  /// Google sign-in (feature 010 research R1). `production_overrides.dart`
  /// binds `GoogleAuth`; tests bind `FakeAccountAuth`.
  AccountAuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountAuthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountAuthHash();

  @$internal
  @override
  $ProviderElement<AccountAuth> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AccountAuth create(Ref ref) {
    return accountAuth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountAuth value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountAuth>(value),
    );
  }
}

String _$accountAuthHash() => r'da1f08355e1b630d90a745bcc03cedc7bd03c61f';

@ProviderFor(accountService)
final accountServiceProvider = AccountServiceProvider._();

final class AccountServiceProvider
    extends $FunctionalProvider<AccountService, AccountService, AccountService>
    with $Provider<AccountService> {
  AccountServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountServiceHash();

  @$internal
  @override
  $ProviderElement<AccountService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AccountService create(Ref ref) {
    return accountService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountService>(value),
    );
  }
}

String _$accountServiceHash() => r'3a8472f54ec1ff65b48c7c90f764bafbac9db398';

/// The signed-in account, for ACC-01 and SET-02.

@ProviderFor(accountState)
final accountStateProvider = AccountStateProvider._();

/// The signed-in account, for ACC-01 and SET-02.

final class AccountStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<AccountState>,
          AccountState,
          Stream<AccountState>
        >
    with $FutureModifier<AccountState>, $StreamProvider<AccountState> {
  /// The signed-in account, for ACC-01 and SET-02.
  AccountStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountStateHash();

  @$internal
  @override
  $StreamProviderElement<AccountState> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AccountState> create(Ref ref) {
    return accountState(ref);
  }
}

String _$accountStateHash() => r'735fce39ee9aa3b1678b8baafa751faa8d6de8b6';

/// The no-backup device ID file. Tests override it with a fake.

@ProviderFor(deviceIdFile)
final deviceIdFileProvider = DeviceIdFileProvider._();

/// The no-backup device ID file. Tests override it with a fake.

final class DeviceIdFileProvider
    extends $FunctionalProvider<DeviceIdFile, DeviceIdFile, DeviceIdFile>
    with $Provider<DeviceIdFile> {
  /// The no-backup device ID file. Tests override it with a fake.
  DeviceIdFileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceIdFileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceIdFileHash();

  @$internal
  @override
  $ProviderElement<DeviceIdFile> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeviceIdFile create(Ref ref) {
    return deviceIdFile(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceIdFile value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceIdFile>(value),
    );
  }
}

String _$deviceIdFileHash() => r'7c05730d8f13569865d3706b4e382c39f2abedc0';

@ProviderFor(deviceIdentityService)
final deviceIdentityServiceProvider = DeviceIdentityServiceProvider._();

final class DeviceIdentityServiceProvider
    extends
        $FunctionalProvider<
          DeviceIdentityService,
          DeviceIdentityService,
          DeviceIdentityService
        >
    with $Provider<DeviceIdentityService> {
  DeviceIdentityServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceIdentityServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceIdentityServiceHash();

  @$internal
  @override
  $ProviderElement<DeviceIdentityService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeviceIdentityService create(Ref ref) {
    return deviceIdentityService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceIdentityService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceIdentityService>(value),
    );
  }
}

String _$deviceIdentityServiceHash() =>
    r'f0536827bced5995bb9a73bd335358146b17dc8a';

/// The one Drive restore path (research R12). Widget tests override it
/// with a fake.

@ProviderFor(accountRestore)
final accountRestoreProvider = AccountRestoreProvider._();

/// The one Drive restore path (research R12). Widget tests override it
/// with a fake.

final class AccountRestoreProvider
    extends $FunctionalProvider<AccountRestore, AccountRestore, AccountRestore>
    with $Provider<AccountRestore> {
  /// The one Drive restore path (research R12). Widget tests override it
  /// with a fake.
  AccountRestoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountRestoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountRestoreHash();

  @$internal
  @override
  $ProviderElement<AccountRestore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AccountRestore create(Ref ref) {
    return accountRestore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountRestore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountRestore>(value),
    );
  }
}

String _$accountRestoreHash() => r'aea7578c8eed373abf4526b75cd3aec527422329';

/// ACC-02 for other features (research R18). Bound in
/// `production_overrides.dart` to the account feature.

@ProviderFor(accountUi)
final accountUiProvider = AccountUiProvider._();

/// ACC-02 for other features (research R18). Bound in
/// `production_overrides.dart` to the account feature.

final class AccountUiProvider
    extends $FunctionalProvider<AccountUi, AccountUi, AccountUi>
    with $Provider<AccountUi> {
  /// ACC-02 for other features (research R18). Bound in
  /// `production_overrides.dart` to the account feature.
  AccountUiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountUiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountUiHash();

  @$internal
  @override
  $ProviderElement<AccountUi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AccountUi create(Ref ref) {
    return accountUi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountUi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountUi>(value),
    );
  }
}

String _$accountUiHash() => r'938b51f4befd7eb3aa2a5881f63e96e410178afd';

/// The shared "Sign in with Google" for ACC-01 and SET-02, and AUTH-01's
/// [AccountSignIn.login].

@ProviderFor(accountSignIn)
final accountSignInProvider = AccountSignInProvider._();

/// The shared "Sign in with Google" for ACC-01 and SET-02, and AUTH-01's
/// [AccountSignIn.login].

final class AccountSignInProvider
    extends $FunctionalProvider<AccountSignIn, AccountSignIn, AccountSignIn>
    with $Provider<AccountSignIn> {
  /// The shared "Sign in with Google" for ACC-01 and SET-02, and AUTH-01's
  /// [AccountSignIn.login].
  AccountSignInProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountSignInProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountSignInHash();

  @$internal
  @override
  $ProviderElement<AccountSignIn> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AccountSignIn create(Ref ref) {
    return accountSignIn(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountSignIn value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountSignIn>(value),
    );
  }
}

String _$accountSignInHash() => r'bc0edfbdff5589d3866170b2ffa9639a31a5a98d';

/// The SET-01 account card (feature 011 data-model §5): a plain provider,
/// not a Notifier, so SET-01 keeps `SettingsController` as its only one.
/// Null while no login is chosen (the router keeps the user on AUTH-01).
/// The card re-reads it on resume, for the network.

@ProviderFor(accountCardView)
final accountCardViewProvider = AccountCardViewProvider._();

/// The SET-01 account card (feature 011 data-model §5): a plain provider,
/// not a Notifier, so SET-01 keeps `SettingsController` as its only one.
/// Null while no login is chosen (the router keeps the user on AUTH-01).
/// The card re-reads it on resume, for the network.

final class AccountCardViewProvider
    extends
        $FunctionalProvider<
          AsyncValue<AccountCardView?>,
          AccountCardView?,
          FutureOr<AccountCardView?>
        >
    with $FutureModifier<AccountCardView?>, $FutureProvider<AccountCardView?> {
  /// The SET-01 account card (feature 011 data-model §5): a plain provider,
  /// not a Notifier, so SET-01 keeps `SettingsController` as its only one.
  /// Null while no login is chosen (the router keeps the user on AUTH-01).
  /// The card re-reads it on resume, for the network.
  AccountCardViewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountCardViewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountCardViewHash();

  @$internal
  @override
  $FutureProviderElement<AccountCardView?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AccountCardView?> create(Ref ref) {
    return accountCardView(ref);
  }
}

String _$accountCardViewHash() => r'425a8ce7ab55c86b62f3830872cd121b5c034994';
