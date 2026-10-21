// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_review_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Widget tests override this with a recording fake.

@ProviderFor(appReviewService)
final appReviewServiceProvider = AppReviewServiceProvider._();

/// Widget tests override this with a recording fake.

final class AppReviewServiceProvider
    extends
        $FunctionalProvider<
          AppReviewService,
          AppReviewService,
          AppReviewService
        >
    with $Provider<AppReviewService> {
  /// Widget tests override this with a recording fake.
  AppReviewServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appReviewServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appReviewServiceHash();

  @$internal
  @override
  $ProviderElement<AppReviewService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppReviewService create(Ref ref) {
    return appReviewService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppReviewService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppReviewService>(value),
    );
  }
}

String _$appReviewServiceHash() => r'7476560b7c23269c7a77c0f20a72076eeab23252';
