/// Whether a budget notification may be shown now (FR-018): the
/// notifications master switch, the Budget alerts setting, and the OS
/// permission must all allow it.
abstract interface class NotificationGate {
  Future<bool> budgetAlertsAllowed();
}
