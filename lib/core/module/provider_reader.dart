import 'package:flutter_riverpod/misc.dart' show ProviderListenable;

/// Reads a provider from whichever host runs a module hook or background
/// task: `ref.read` in the app, `ProviderContainer.read` in the background
/// isolate and tests (feature 003 research R10). Modules stay `const`, and
/// core never imports a feature.
typedef ProviderReader = T Function<T>(ProviderListenable<T> provider);
