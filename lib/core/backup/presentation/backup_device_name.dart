import 'package:dailytrack/core/account/domain/device_identity.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';

/// A backup's device name as shown to the user (feature 010 spec
/// Assumptions): a phone that reported neither manufacturer nor model
/// stores [DeviceIdentityPolicy.fallbackName], shown as "Android phone" in
/// the user's language. Every other name is shown as stored.
String backupDeviceName(AppLocalizations l10n, String name) =>
    name == DeviceIdentityPolicy.fallbackName
    ? l10n.account_androidPhone
    : name;
