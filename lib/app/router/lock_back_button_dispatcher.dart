import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// The app's back button handler (feature 007 research R7). While the app
/// is locked, back closes the app instead of popping the screen under the
/// SYS-03 overlay, so it never reveals anything (FR-034).
class LockAwareBackButtonDispatcher extends RootBackButtonDispatcher {
  new({required this.isLocked});

  final bool Function() isLocked;

  @override
  Future<bool> didPopRoute() async {
    if (isLocked()) {
      await SystemNavigator.pop();
      return true;
    }
    return await super.didPopRoute();
  }
}
