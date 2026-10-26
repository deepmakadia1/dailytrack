import 'package:dailytrack/core/ads/domain/ad_config.dart';

/// Session rules for the interstitial cap (spec §11, clarification Q3): a
/// session starts on a cold start, or when the app returns after at least
/// [AdConfig.sessionGap] in the background. Pure Dart.
final class AdSession {
  const new(this.config);

  final AdConfig config;

  /// Whether returning to the foreground at [now] starts a new session.
  /// A shorter trip out (a full-screen ad, the share sheet) does not.
  bool isNewSession({required DateTime now, DateTime? backgroundedAt}) =>
      backgroundedAt != null &&
      now.difference(backgroundedAt) >= config.sessionGap;

  /// Starts a session on local day [todayKey]. It is the first session of
  /// the day when no session started on that day before. The flag is kept
  /// for the whole session, even across midnight.
  ({bool isFirstSessionOfDay, String lastSessionDayKey}) start({
    required String todayKey,
    String? lastSessionDayKey,
  }) => (
    isFirstSessionOfDay: todayKey != lastSessionDayKey,
    lastSessionDayKey: todayKey,
  );
}
