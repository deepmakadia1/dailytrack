import 'package:dailytrack/core/ads/domain/ad_config.dart';
import 'package:dailytrack/core/ads/domain/ad_trigger.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'interstitial_cap.freezed.dart';

/// What the global interstitial cap remembers (spec §11, feature 009
/// data-model §3). [installAt], [lastShownAt], [dayKey], and [shownToday]
/// are stored in settings; [isFirstSessionOfDay] and [expenseSaves] live
/// only for the current session. Pure Dart.
@freezed
abstract class InterstitialCapState with _$InterstitialCapState {
  const factory({
    /// UTC.
    required DateTime installAt,

    /// UTC. Null until the first interstitial.
    DateTime? lastShownAt,

    /// Local `yyyy-MM-dd` that [shownToday] counts for.
    String? dayKey,
    @Default(0) int shownToday,

    /// The current session is the user's first of the local day.
    @Default(false) bool isFirstSessionOfDay,

    /// New EXP-02 entries saved in this session since the last interstitial.
    @Default(0) int expenseSaves,
  }) = _InterstitialCapState;
}

/// Why no interstitial was shown. The pure cap returns the first five; the
/// ad service adds the rest.
enum CapBlockReason {
  installAge,
  firstSession,
  gap,
  dailyMax,
  notEnoughSaves,
  notPreloaded,
  notOnReadingScreen,
  adsDisabled,
}

/// The cap's answer for one trigger.
sealed class CapDecision {
  const new();
}

final class CapAllow extends CapDecision {
  const new();
}

@immutable
final class CapBlock extends CapDecision {
  const new(this.reason);

  final CapBlockReason reason;

  @override
  bool operator ==(Object other) => other is CapBlock && other.reason == reason;

  @override
  int get hashCode => reason.hashCode;

  @override
  String toString() => 'CapBlock($reason)';
}

/// The global interstitial frequency cap (spec §11, FR-020, FR-022). Total
/// and clock-free: callers pass the effective now (the later of the clock
/// and `latestSeenAt`) and the local day key.
final class InterstitialCap {
  const new(this.config);

  final AdConfig config;

  /// Checks, in order: install age, first session of the day, the minimum
  /// gap, the daily maximum, and (for EXP-02 saves) the save count.
  CapDecision check(
    InterstitialCapState state, {
    required DateTime effectiveNow,
    required String todayKey,
    required AdTrigger trigger,
  }) {
    final installAge = Duration(days: config.installAgeDays);
    if (effectiveNow.difference(state.installAt) < installAge) {
      return const CapBlock(CapBlockReason.installAge);
    }
    if (state.isFirstSessionOfDay) {
      return const CapBlock(CapBlockReason.firstSession);
    }
    final last = state.lastShownAt;
    if (last != null && effectiveNow.difference(last) < config.minGap) {
      return const CapBlock(CapBlockReason.gap);
    }
    if (state.dayKey == todayKey && state.shownToday >= config.maxPerDay) {
      return const CapBlock(CapBlockReason.dailyMax);
    }
    if (trigger is ExpenseSaved &&
        state.expenseSaves < config.savesPerInterstitial) {
      return const CapBlock(CapBlockReason.notEnoughSaves);
    }
    return const CapAllow();
  }

  /// After an interstitial was shown: remember when, count it for the day,
  /// and reset the save counter.
  InterstitialCapState afterShown(
    InterstitialCapState state, {
    required DateTime now,
    required String todayKey,
  }) => state.copyWith(
    lastShownAt: now,
    dayKey: todayKey,
    shownToday: state.dayKey == todayKey ? state.shownToday + 1 : 1,
    expenseSaves: 0,
  );

  /// After a new EXP-02 entry was saved. Blocking never resets the counter.
  InterstitialCapState afterExpenseSave(InterstitialCapState state) =>
      state.copyWith(expenseSaves: state.expenseSaves + 1);
}
