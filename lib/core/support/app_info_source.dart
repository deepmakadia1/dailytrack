import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_info_source.g.dart';

/// The installed app's version, build number, and package name (SET-01
/// About, feedback email).
final class AppInfo {
  const new({
    required this.version,
    required this.buildNumber,
    required this.packageName,
  });

  final String version;
  final String buildNumber;
  final String packageName;
}

abstract interface class AppInfoSource {
  Future<AppInfo> load();
}

/// `package_info_plus`. Platform call only, so it is covered by the device
/// check.
// coverage:ignore-start
final class PackageInfoSource implements AppInfoSource {
  const new();

  @override
  Future<AppInfo> load() async {
    final info = await PackageInfo.fromPlatform();
    return AppInfo(
      version: info.version,
      buildNumber: info.buildNumber,
      packageName: info.packageName,
    );
  }
}
// coverage:ignore-end

/// Widget tests override this with a fixed fake.
@Riverpod(keepAlive: true)
AppInfoSource appInfoSource(Ref ref) => const PackageInfoSource();
