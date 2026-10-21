import 'package:dailytrack/core/security/domain/lock_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'security_providers.g.dart';

/// The app lock, typed to the domain interface so presentation code can
/// depend on it (Constitution II). `production_overrides.dart` binds
/// `SecureLockService`; widget tests bind `FakeLockService`.
@Riverpod(keepAlive: true)
LockService lockService(Ref ref) =>
    throw UnimplementedError('lockServiceProvider must be overridden');
