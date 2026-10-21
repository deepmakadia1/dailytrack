import 'package:dailytrack/core/security/lock_session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'external_activity_guard.g.dart';

/// Lets code that opens another app (camera, share sheet, email, store)
/// say so first, so "Lock after: Immediately" does not show SYS-03 on the
/// way back (feature 007 research R15). Callers see only this, never the
/// session.
final class ExternalActivityGuard {
  const new(this._expect);

  final void Function() _expect;

  void expectExternalActivity() => _expect();
}

@Riverpod(keepAlive: true)
ExternalActivityGuard externalActivityGuard(Ref ref) => ExternalActivityGuard(
  () => ref.read(lockSessionProvider.notifier).expectExternalActivity(),
);
