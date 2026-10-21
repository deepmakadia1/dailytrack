import 'dart:ui' show lerpDouble;

import 'package:dailytrack/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// App-specific design tokens (spec §15.2, contracts/app_tokens.md).
/// Widgets read these through [AppTokens.of] instead of hard-coding values.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const new({
    required this.income,
    required this.expense,
    required this.warning,
    required this.success,
    required this.adBadge,
    required this.habitDoneDarkOpacity,
    this.s4 = 4,
    this.s8 = 8,
    this.s12 = 12,
    this.s16 = 16,
    this.s24 = 24,
    this.s32 = 32,
    this.s48 = 48,
    this.screenPadding = 16,
    this.screenPaddingWide = 24,
    this.cardGap = 12,
    this.wideBreakpoint = 600,
    this.maxContentWidth = 600,
    this.radiusChip = 8,
    this.radiusCard = 16,
    this.radiusSheet = 28,
    this.iconSize = 24,
    this.chipIconSize = 20,
    this.avatarSize = 40,
    this.minTouchTarget = 48,
    this.navBarHeight = 80,
    this.motionShort = const Duration(milliseconds: 150),
    this.motionMedium = const Duration(milliseconds: 250),
    this.motionSize = const Duration(milliseconds: 200),
  });

  factory light(ColorScheme scheme) => AppTokens(
    income: AppColors.incomeLight,
    expense: AppColors.expenseLight,
    warning: AppColors.warningLight,
    success: AppColors.successLight,
    adBadge: scheme.surfaceContainerHighest,
    habitDoneDarkOpacity: 1,
  );

  factory dark(ColorScheme scheme) => AppTokens(
    income: AppColors.incomeDark,
    expense: AppColors.expenseDark,
    warning: AppColors.warningDark,
    success: AppColors.successDark,
    adBadge: scheme.surfaceContainerHighest,
    habitDoneDarkOpacity: 0.85,
  );

  static AppTokens of(BuildContext context) =>
      Theme.of(context).extension<AppTokens>()!;

  final Color income;
  final Color expense;
  final Color warning;
  final Color success;
  final Color adBadge;
  final double habitDoneDarkOpacity;

  final double s4;
  final double s8;
  final double s12;
  final double s16;
  final double s24;
  final double s32;
  final double s48;
  final double screenPadding;
  final double screenPaddingWide;
  final double cardGap;
  final double wideBreakpoint;
  final double maxContentWidth;

  final double radiusChip;
  final double radiusCard;
  final double radiusSheet;

  final double iconSize;
  final double chipIconSize;
  final double avatarSize;
  final double minTouchTarget;
  final double navBarHeight;

  final Duration motionShort;
  final Duration motionMedium;

  /// Height changes of late-loading content and hiding controls (§15.6).
  final Duration motionSize;

  /// Side padding for a screen of the given width (16 dp, or 24 dp when wide).
  double sidePadding(double width) =>
      width > wideBreakpoint ? screenPaddingWide : screenPadding;

  @override
  AppTokens copyWith({
    Color? income,
    Color? expense,
    Color? warning,
    Color? success,
    Color? adBadge,
    double? habitDoneDarkOpacity,
  }) {
    return AppTokens(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      warning: warning ?? this.warning,
      success: success ?? this.success,
      adBadge: adBadge ?? this.adBadge,
      habitDoneDarkOpacity: habitDoneDarkOpacity ?? this.habitDoneDarkOpacity,
      s4: s4,
      s8: s8,
      s12: s12,
      s16: s16,
      s24: s24,
      s32: s32,
      s48: s48,
      screenPadding: screenPadding,
      screenPaddingWide: screenPaddingWide,
      cardGap: cardGap,
      wideBreakpoint: wideBreakpoint,
      maxContentWidth: maxContentWidth,
      radiusChip: radiusChip,
      radiusCard: radiusCard,
      radiusSheet: radiusSheet,
      iconSize: iconSize,
      chipIconSize: chipIconSize,
      avatarSize: avatarSize,
      minTouchTarget: minTouchTarget,
      navBarHeight: navBarHeight,
      motionShort: motionShort,
      motionMedium: motionMedium,
      motionSize: motionSize,
    );
  }

  @override
  AppTokens lerp(covariant AppTokens? other, double t) {
    if (other == null) return this;
    return AppTokens(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      success: Color.lerp(success, other.success, t)!,
      adBadge: Color.lerp(adBadge, other.adBadge, t)!,
      habitDoneDarkOpacity: lerpDouble(
        habitDoneDarkOpacity,
        other.habitDoneDarkOpacity,
        t,
      )!,
    );
  }
}
