// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(habitRepository)
final habitRepositoryProvider = HabitRepositoryProvider._();

final class HabitRepositoryProvider
    extends
        $FunctionalProvider<HabitRepository, HabitRepository, HabitRepository>
    with $Provider<HabitRepository> {
  HabitRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'habitRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$habitRepositoryHash();

  @$internal
  @override
  $ProviderElement<HabitRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HabitRepository create(Ref ref) {
    return habitRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HabitRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HabitRepository>(value),
    );
  }
}

String _$habitRepositoryHash() => r'3813ad12b11a81df6d8786004557dbfaf06a3a2d';

@ProviderFor(habitEntryRepository)
final habitEntryRepositoryProvider = HabitEntryRepositoryProvider._();

final class HabitEntryRepositoryProvider
    extends
        $FunctionalProvider<
          HabitEntryRepository,
          HabitEntryRepository,
          HabitEntryRepository
        >
    with $Provider<HabitEntryRepository> {
  HabitEntryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'habitEntryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$habitEntryRepositoryHash();

  @$internal
  @override
  $ProviderElement<HabitEntryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HabitEntryRepository create(Ref ref) {
    return habitEntryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HabitEntryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HabitEntryRepository>(value),
    );
  }
}

String _$habitEntryRepositoryHash() =>
    r'a354fbe7234657ee1181f6e9c9b48b039932434a';

@ProviderFor(habitReminderScheduler)
final habitReminderSchedulerProvider = HabitReminderSchedulerProvider._();

final class HabitReminderSchedulerProvider
    extends
        $FunctionalProvider<
          HabitReminderScheduler,
          HabitReminderScheduler,
          HabitReminderScheduler
        >
    with $Provider<HabitReminderScheduler> {
  HabitReminderSchedulerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'habitReminderSchedulerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$habitReminderSchedulerHash();

  @$internal
  @override
  $ProviderElement<HabitReminderScheduler> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HabitReminderScheduler create(Ref ref) {
    return habitReminderScheduler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HabitReminderScheduler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HabitReminderScheduler>(value),
    );
  }
}

String _$habitReminderSchedulerHash() =>
    r'96e5fe84ae5d1ac9a3da995798e09364a7e376aa';

/// The user's first day of the week (settings, default Monday).

@ProviderFor(firstDayOfWeek)
final firstDayOfWeekProvider = FirstDayOfWeekProvider._();

/// The user's first day of the week (settings, default Monday).

final class FirstDayOfWeekProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// The user's first day of the week (settings, default Monday).
  FirstDayOfWeekProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firstDayOfWeekProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firstDayOfWeekHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return firstDayOfWeek(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$firstDayOfWeekHash() => r'958359b95ff7ef50053a9c85bbb6ac2ad42995aa';

/// Streak rules with the app clock (research R6); rebuilt when the first
/// day of the week changes.

@ProviderFor(streakEngine)
final streakEngineProvider = StreakEngineProvider._();

/// Streak rules with the app clock (research R6); rebuilt when the first
/// day of the week changes.

final class StreakEngineProvider
    extends $FunctionalProvider<StreakEngine, StreakEngine, StreakEngine>
    with $Provider<StreakEngine> {
  /// Streak rules with the app clock (research R6); rebuilt when the first
  /// day of the week changes.
  StreakEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'streakEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$streakEngineHash();

  @$internal
  @override
  $ProviderElement<StreakEngine> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StreakEngine create(Ref ref) {
    return streakEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StreakEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StreakEngine>(value),
    );
  }
}

String _$streakEngineHash() => r'faf0d9e221d90689eefdae5dc3dbbf9594d06089';

/// Every day write goes through this (research R8). Composed from bound
/// providers; needs no binding.

@ProviderFor(habitDayWriter)
final habitDayWriterProvider = HabitDayWriterProvider._();

/// Every day write goes through this (research R8). Composed from bound
/// providers; needs no binding.

final class HabitDayWriterProvider
    extends $FunctionalProvider<HabitDayWriter, HabitDayWriter, HabitDayWriter>
    with $Provider<HabitDayWriter> {
  /// Every day write goes through this (research R8). Composed from bound
  /// providers; needs no binding.
  HabitDayWriterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'habitDayWriterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$habitDayWriterHash();

  @$internal
  @override
  $ProviderElement<HabitDayWriter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HabitDayWriter create(Ref ref) {
    return habitDayWriter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HabitDayWriter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HabitDayWriter>(value),
    );
  }
}

String _$habitDayWriterHash() => r'2438a418d10c9488e01954ac27a51b67e7097a87';
