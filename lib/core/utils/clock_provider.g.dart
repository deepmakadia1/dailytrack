// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app clock (`package:clock`, research R2 of feature 003). Every time
/// read in `lib/` goes through it, so tests can override it with
/// `Clock.fixed` or `MutableClock`. `const Clock()` reads the zone-aware
/// `clock` global, so `withClock` works too.

@ProviderFor(clock)
final clockProvider = ClockProvider._();

/// The app clock (`package:clock`, research R2 of feature 003). Every time
/// read in `lib/` goes through it, so tests can override it with
/// `Clock.fixed` or `MutableClock`. `const Clock()` reads the zone-aware
/// `clock` global, so `withClock` works too.

final class ClockProvider extends $FunctionalProvider<Clock, Clock, Clock>
    with $Provider<Clock> {
  /// The app clock (`package:clock`, research R2 of feature 003). Every time
  /// read in `lib/` goes through it, so tests can override it with
  /// `Clock.fixed` or `MutableClock`. `const Clock()` reads the zone-aware
  /// `clock` global, so `withClock` works too.
  ClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clockHash();

  @$internal
  @override
  $ProviderElement<Clock> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Clock create(Ref ref) {
    return clock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Clock value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Clock>(value),
    );
  }
}

String _$clockHash() => r'30e71d378a201482bb785bc8babd9bfcb65538f7';
