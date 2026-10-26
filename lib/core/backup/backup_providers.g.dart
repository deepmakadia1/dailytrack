// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// System save and open dialogs. Widget tests override this with a fake.

@ProviderFor(localBackupFiles)
final localBackupFilesProvider = LocalBackupFilesProvider._();

/// System save and open dialogs. Widget tests override this with a fake.

final class LocalBackupFilesProvider
    extends
        $FunctionalProvider<
          LocalBackupFiles,
          LocalBackupFiles,
          LocalBackupFiles
        >
    with $Provider<LocalBackupFiles> {
  /// System save and open dialogs. Widget tests override this with a fake.
  LocalBackupFilesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localBackupFilesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localBackupFilesHash();

  @$internal
  @override
  $ProviderElement<LocalBackupFiles> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocalBackupFiles create(Ref ref) {
    return localBackupFiles(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalBackupFiles value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalBackupFiles>(value),
    );
  }
}

String _$localBackupFilesHash() => r'bbf663e7899d214d067c50bd8718dbc6c532ff82';

/// Whether Google Drive backup is configured in this build (research R10).
/// Widget tests override it.

@ProviderFor(driveAvailable)
final driveAvailableProvider = DriveAvailableProvider._();

/// Whether Google Drive backup is configured in this build (research R10).
/// Widget tests override it.

final class DriveAvailableProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether Google Drive backup is configured in this build (research R10).
  /// Widget tests override it.
  DriveAvailableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driveAvailableProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driveAvailableHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return driveAvailable(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$driveAvailableHash() => r'cf08d333c2dd029f51458c698ebfb795dca57e7f';

/// Google sign-in, shared so initialization happens once.

@ProviderFor(googleAuth)
final googleAuthProvider = GoogleAuthProvider._();

/// Google sign-in, shared so initialization happens once.

final class GoogleAuthProvider
    extends $FunctionalProvider<GoogleAuth, GoogleAuth, GoogleAuth>
    with $Provider<GoogleAuth> {
  /// Google sign-in, shared so initialization happens once.
  GoogleAuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'googleAuthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$googleAuthHash();

  @$internal
  @override
  $ProviderElement<GoogleAuth> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoogleAuth create(Ref ref) {
    return googleAuth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoogleAuth value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoogleAuth>(value),
    );
  }
}

String _$googleAuthHash() => r'4e4d3d6a21ebf1a8a5ab54f3aa220672f9711cf8';

/// The user's Drive app folder (feature 008 research R10). Widget tests
/// override this with a fake.

@ProviderFor(driveBackupStore)
final driveBackupStoreProvider = DriveBackupStoreProvider._();

/// The user's Drive app folder (feature 008 research R10). Widget tests
/// override this with a fake.

final class DriveBackupStoreProvider
    extends
        $FunctionalProvider<
          DriveBackupStore,
          DriveBackupStore,
          DriveBackupStore
        >
    with $Provider<DriveBackupStore> {
  /// The user's Drive app folder (feature 008 research R10). Widget tests
  /// override this with a fake.
  DriveBackupStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driveBackupStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driveBackupStoreHash();

  @$internal
  @override
  $ProviderElement<DriveBackupStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DriveBackupStore create(Ref ref) {
    return driveBackupStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriveBackupStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriveBackupStore>(value),
    );
  }
}

String _$driveBackupStoreHash() => r'0e2cccf3ceaa4a89d66b6c8c161b8320201c86b5';

/// The backup password in secure storage (feature 008 research R4).

@ProviderFor(backupPasswordStore)
final backupPasswordStoreProvider = BackupPasswordStoreProvider._();

/// The backup password in secure storage (feature 008 research R4).

final class BackupPasswordStoreProvider
    extends
        $FunctionalProvider<
          BackupPasswordStore,
          BackupPasswordStore,
          BackupPasswordStore
        >
    with $Provider<BackupPasswordStore> {
  /// The backup password in secure storage (feature 008 research R4).
  BackupPasswordStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupPasswordStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupPasswordStoreHash();

  @$internal
  @override
  $ProviderElement<BackupPasswordStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BackupPasswordStore create(Ref ref) {
    return backupPasswordStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupPasswordStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupPasswordStore>(value),
    );
  }
}

String _$backupPasswordStoreHash() =>
    r'5099548986bb317072627f9c6ad08ae3280468ea';

/// Where receipts live; tests point this at a temporary folder.

@ProviderFor(backupDocumentsDir)
final backupDocumentsDirProvider = BackupDocumentsDirProvider._();

/// Where receipts live; tests point this at a temporary folder.

final class BackupDocumentsDirProvider
    extends
        $FunctionalProvider<
          Future<Directory> Function(),
          Future<Directory> Function(),
          Future<Directory> Function()
        >
    with $Provider<Future<Directory> Function()> {
  /// Where receipts live; tests point this at a temporary folder.
  BackupDocumentsDirProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupDocumentsDirProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupDocumentsDirHash();

  @$internal
  @override
  $ProviderElement<Future<Directory> Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Future<Directory> Function() create(Ref ref) {
    return backupDocumentsDir(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Future<Directory> Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Future<Directory> Function()>(value),
    );
  }
}

String _$backupDocumentsDirHash() =>
    r'daecebb90c45b2cbee58e744a598f7ac264fdb63';

/// Where backup copies are kept for sharing.

@ProviderFor(backupCacheDir)
final backupCacheDirProvider = BackupCacheDirProvider._();

/// Where backup copies are kept for sharing.

final class BackupCacheDirProvider
    extends
        $FunctionalProvider<
          Future<Directory> Function(),
          Future<Directory> Function(),
          Future<Directory> Function()
        >
    with $Provider<Future<Directory> Function()> {
  /// Where backup copies are kept for sharing.
  BackupCacheDirProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupCacheDirProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupCacheDirHash();

  @$internal
  @override
  $ProviderElement<Future<Directory> Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Future<Directory> Function() create(Ref ref) {
    return backupCacheDir(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Future<Directory> Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Future<Directory> Function()>(value),
    );
  }
}

String _$backupCacheDirHash() => r'c38102caaca15be867279ddefcfa43529c617b66';

/// The 7-day safety copy in app support (feature 010 data-model §5).
/// Widget tests override it with a fake.

@ProviderFor(safetyCopyStore)
final safetyCopyStoreProvider = SafetyCopyStoreProvider._();

/// The 7-day safety copy in app support (feature 010 data-model §5).
/// Widget tests override it with a fake.

final class SafetyCopyStoreProvider
    extends
        $FunctionalProvider<SafetyCopyStore, SafetyCopyStore, SafetyCopyStore>
    with $Provider<SafetyCopyStore> {
  /// The 7-day safety copy in app support (feature 010 data-model §5).
  /// Widget tests override it with a fake.
  SafetyCopyStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'safetyCopyStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$safetyCopyStoreHash();

  @$internal
  @override
  $ProviderElement<SafetyCopyStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SafetyCopyStore create(Ref ref) {
    return safetyCopyStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SafetyCopyStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SafetyCopyStore>(value),
    );
  }
}

String _$safetyCopyStoreHash() => r'76dfbe0a6c69f1a8c465b641764faa12932697eb';

/// Runs after a restore: reschedule notifications and run app-open work
/// (FR-010). Bound in `lib/app/production_overrides.dart`, because core never
/// imports `lib/app/` (feature 008 research R8).

@ProviderFor(restoreAftermath)
final restoreAftermathProvider = RestoreAftermathProvider._();

/// Runs after a restore: reschedule notifications and run app-open work
/// (FR-010). Bound in `lib/app/production_overrides.dart`, because core never
/// imports `lib/app/` (feature 008 research R8).

final class RestoreAftermathProvider
    extends
        $FunctionalProvider<
          Future<void> Function(),
          Future<void> Function(),
          Future<void> Function()
        >
    with $Provider<Future<void> Function()> {
  /// Runs after a restore: reschedule notifications and run app-open work
  /// (FR-010). Bound in `lib/app/production_overrides.dart`, because core never
  /// imports `lib/app/` (feature 008 research R8).
  RestoreAftermathProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'restoreAftermathProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$restoreAftermathHash();

  @$internal
  @override
  $ProviderElement<Future<void> Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Future<void> Function() create(Ref ref) {
    return restoreAftermath(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Future<void> Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Future<void> Function()>(value),
    );
  }
}

String _$restoreAftermathHash() => r'cbe109a80ccce08d1934e946b6d66e5d89247419';

@ProviderFor(backupCoordinator)
final backupCoordinatorProvider = BackupCoordinatorProvider._();

final class BackupCoordinatorProvider
    extends
        $FunctionalProvider<
          BackupCoordinator,
          BackupCoordinator,
          BackupCoordinator
        >
    with $Provider<BackupCoordinator> {
  BackupCoordinatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupCoordinatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupCoordinatorHash();

  @$internal
  @override
  $ProviderElement<BackupCoordinator> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BackupCoordinator create(Ref ref) {
    return backupCoordinator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupCoordinator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupCoordinator>(value),
    );
  }
}

String _$backupCoordinatorHash() => r'd5dd58055a95ffae166d011c878f30d56d0cb5ce';

@ProviderFor(backupEngine)
final backupEngineProvider = BackupEngineProvider._();

final class BackupEngineProvider
    extends $FunctionalProvider<BackupEngine, BackupEngine, BackupEngine>
    with $Provider<BackupEngine> {
  BackupEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupEngineHash();

  @$internal
  @override
  $ProviderElement<BackupEngine> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BackupEngine create(Ref ref) {
    return backupEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupEngine>(value),
    );
  }
}

String _$backupEngineHash() => r'698384713a13a00c3ebd3a213e68400da88fa69b';

@ProviderFor(backupService)
final backupServiceProvider = BackupServiceProvider._();

final class BackupServiceProvider
    extends $FunctionalProvider<BackupService, BackupService, BackupService>
    with $Provider<BackupService> {
  BackupServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupServiceHash();

  @$internal
  @override
  $ProviderElement<BackupService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BackupService create(Ref ref) {
    return backupService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupService>(value),
    );
  }
}

String _$backupServiceHash() => r'7041747f54587cfdade069a3f1898ecbd69fba67';

@ProviderFor(restoreService)
final restoreServiceProvider = RestoreServiceProvider._();

final class RestoreServiceProvider
    extends $FunctionalProvider<RestoreService, RestoreService, RestoreService>
    with $Provider<RestoreService> {
  RestoreServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'restoreServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$restoreServiceHash();

  @$internal
  @override
  $ProviderElement<RestoreService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RestoreService create(Ref ref) {
    return restoreService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RestoreService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RestoreService>(value),
    );
  }
}

String _$restoreServiceHash() => r'743ab8a4c320111e255f2d5c2bb5cb90afd21261';

/// Starts a background backup when the app is hidden (feature 010 R6).

@ProviderFor(backgroundBackupScheduler)
final backgroundBackupSchedulerProvider = BackgroundBackupSchedulerProvider._();

/// Starts a background backup when the app is hidden (feature 010 R6).

final class BackgroundBackupSchedulerProvider
    extends
        $FunctionalProvider<
          BackgroundBackupScheduler,
          BackgroundBackupScheduler,
          BackgroundBackupScheduler
        >
    with $Provider<BackgroundBackupScheduler> {
  /// Starts a background backup when the app is hidden (feature 010 R6).
  BackgroundBackupSchedulerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backgroundBackupSchedulerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backgroundBackupSchedulerHash();

  @$internal
  @override
  $ProviderElement<BackgroundBackupScheduler> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BackgroundBackupScheduler create(Ref ref) {
    return backgroundBackupScheduler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackgroundBackupScheduler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackgroundBackupScheduler>(value),
    );
  }
}

String _$backgroundBackupSchedulerHash() =>
    r'42283f6faa36bbb43db534909d82296645fd7749';
