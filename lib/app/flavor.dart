import 'package:flutter/services.dart';

enum Flavor { dev, prod }

/// Build flavor resolved from `--flavor` (research R2). Anything that is not
/// `prod` is treated as `dev`, so tests and plain `flutter run` stay on dev.
final class FlavorConfig {
  const new(this.flavor);

  factory fromName(String? name) =>
      FlavorConfig(name == 'prod' ? Flavor.prod : Flavor.dev);

  static final FlavorConfig current = FlavorConfig.fromName(appFlavor);

  final Flavor flavor;

  bool get isProd => flavor == Flavor.prod;
}
