import 'package:dailytrack/core/ads/ad_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ad_providers.g.dart';

/// Phase 0 has no ads SDK (research R8); T4.1 binds the real service.
@Riverpod(keepAlive: true)
AdService adService(Ref ref) => const NoAdsService();
