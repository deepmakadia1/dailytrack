import 'package:clock/clock.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock_provider.g.dart';

/// The app clock (`package:clock`, research R2 of feature 003). Every time
/// read in `lib/` goes through it, so tests can override it with
/// `Clock.fixed` or `MutableClock`. `const Clock()` reads the zone-aware
/// `clock` global, so `withClock` works too.
@Riverpod(keepAlive: true)
Clock clock(Ref ref) => const Clock();
