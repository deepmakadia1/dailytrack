import 'package:dailytrack/core/background/background_scheduler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'background_providers.g.dart';

/// Daily background jobs (research R10). `production_overrides.dart` binds
/// `WorkmanagerBackgroundScheduler`; tests bind `FakeBackgroundScheduler`.
@Riverpod(keepAlive: true)
BackgroundScheduler backgroundScheduler(Ref ref) =>
    throw UnimplementedError('backgroundSchedulerProvider must be overridden');
