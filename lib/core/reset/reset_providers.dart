import 'package:dailytrack/core/reset/domain/app_reset_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reset_providers.g.dart';

/// Erase all data, typed to the domain interface so presentation code can
/// depend on it (Constitution II). `production_overrides.dart` binds
/// `DriftAppResetService`; widget tests bind a fake or a real one over an
/// in-memory database.
@Riverpod(keepAlive: true)
AppResetService appResetService(Ref ref) =>
    throw UnimplementedError('appResetServiceProvider must be overridden');
