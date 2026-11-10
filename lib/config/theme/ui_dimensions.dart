import 'dart:ui';

import 'package:flutter/material.dart';

enum UiDensity { comfortable, compact }

@immutable
class UiDimensions extends ThemeExtension<UiDimensions> {
  final double pagePadding;
  final double cardPadding;
  final double sectionGap;
  final double rowGap;
  final double headerInset;
  final double headerHeight;
  final double navigationInset;
  final double heroAspectRatio;
  final double calendarRowHeight;
  final double avatarRadius;
  final double densePagePadding;
  final double denseCardPadding;
  final double profileNameFontSize;
  final double statValueFontSize;

  const UiDimensions({
    required this.pagePadding,
    required this.cardPadding,
    required this.sectionGap,
    required this.rowGap,
    required this.headerInset,
    required this.headerHeight,
    required this.navigationInset,
    required this.heroAspectRatio,
    required this.calendarRowHeight,
    required this.avatarRadius,
    required this.densePagePadding,
    required this.denseCardPadding,
    required this.profileNameFontSize,
    required this.statValueFontSize,
  });

  static const comfortable = UiDimensions(
    pagePadding: 14,
    cardPadding: 11,
    sectionGap: 14,
    rowGap: 8,
    headerInset: 11,
    headerHeight: 48,
    navigationInset: 9,
    heroAspectRatio: 335 / 128,
    calendarRowHeight: 48,
    avatarRadius: 37,
    densePagePadding: 9,
    denseCardPadding: 9,
    profileNameFontSize: 18,
    statValueFontSize: 16,
  );

  static const compact = UiDimensions(
    pagePadding: 10,
    cardPadding: 9,
    sectionGap: 10,
    rowGap: 6,
    headerInset: 8,
    headerHeight: 48,
    navigationInset: 7,
    heroAspectRatio: 335 / 120,
    calendarRowHeight: 48,
    avatarRadius: 33,
    densePagePadding: 7,
    denseCardPadding: 7,
    profileNameFontSize: 17,
    statValueFontSize: 15,
  );

  static UiDimensions of(BuildContext context) =>
      Theme.of(context).extension<UiDimensions>() ?? comfortable;

  @override
  UiDimensions copyWith({
    double? pagePadding,
    double? cardPadding,
    double? sectionGap,
    double? rowGap,
    double? headerInset,
    double? headerHeight,
    double? navigationInset,
    double? heroAspectRatio,
    double? calendarRowHeight,
    double? avatarRadius,
    double? densePagePadding,
    double? denseCardPadding,
    double? profileNameFontSize,
    double? statValueFontSize,
  }) => UiDimensions(
    pagePadding: pagePadding ?? this.pagePadding,
    cardPadding: cardPadding ?? this.cardPadding,
    sectionGap: sectionGap ?? this.sectionGap,
    rowGap: rowGap ?? this.rowGap,
    headerInset: headerInset ?? this.headerInset,
    headerHeight: headerHeight ?? this.headerHeight,
    navigationInset: navigationInset ?? this.navigationInset,
    heroAspectRatio: heroAspectRatio ?? this.heroAspectRatio,
    calendarRowHeight: calendarRowHeight ?? this.calendarRowHeight,
    avatarRadius: avatarRadius ?? this.avatarRadius,
    densePagePadding: densePagePadding ?? this.densePagePadding,
    denseCardPadding: denseCardPadding ?? this.denseCardPadding,
    profileNameFontSize: profileNameFontSize ?? this.profileNameFontSize,
    statValueFontSize: statValueFontSize ?? this.statValueFontSize,
  );

  @override
  UiDimensions lerp(ThemeExtension<UiDimensions>? other, double t) {
    if (other is! UiDimensions) return this;
    return UiDimensions(
      pagePadding: lerpDouble(pagePadding, other.pagePadding, t)!,
      cardPadding: lerpDouble(cardPadding, other.cardPadding, t)!,
      sectionGap: lerpDouble(sectionGap, other.sectionGap, t)!,
      rowGap: lerpDouble(rowGap, other.rowGap, t)!,
      headerInset: lerpDouble(headerInset, other.headerInset, t)!,
      headerHeight: lerpDouble(headerHeight, other.headerHeight, t)!,
      navigationInset: lerpDouble(navigationInset, other.navigationInset, t)!,
      heroAspectRatio: lerpDouble(heroAspectRatio, other.heroAspectRatio, t)!,
      calendarRowHeight: lerpDouble(
        calendarRowHeight,
        other.calendarRowHeight,
        t,
      )!,
      avatarRadius: lerpDouble(avatarRadius, other.avatarRadius, t)!,
      densePagePadding: lerpDouble(
        densePagePadding,
        other.densePagePadding,
        t,
      )!,
      denseCardPadding: lerpDouble(
        denseCardPadding,
        other.denseCardPadding,
        t,
      )!,
      profileNameFontSize: lerpDouble(
        profileNameFontSize,
        other.profileNameFontSize,
        t,
      )!,
      statValueFontSize: lerpDouble(
        statValueFontSize,
        other.statValueFontSize,
        t,
      )!,
    );
  }
}
