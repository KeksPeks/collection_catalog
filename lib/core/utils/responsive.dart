import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Адаптивные параметры приложения.
/// Размер интерфейса определяется доступной шириной окна, а не физическими пикселями.
class ResponsiveInfo {
  final Size size;
  final double contentWidth;
  final bool isPhone;
  final bool isTablet;
  final bool isLargeTablet;
  final bool isFoldable;
  final bool useRail;
  final double layoutScale;
  final double pagePadding;
  final double contentMaxWidth;
  final int gridColumns;

  const ResponsiveInfo({required this.size, required this.contentWidth, required this.isPhone, required this.isTablet, required this.isLargeTablet, required this.isFoldable, required this.useRail, required this.layoutScale, required this.pagePadding, required this.contentMaxWidth, required this.gridColumns});

  factory ResponsiveInfo.fromMediaQuery(MediaQueryData media) {
    final size = media.size;
    final verticalHinge = media.displayFeatures.where((feature) {
      return (feature.type == ui.DisplayFeatureType.hinge || feature.type == ui.DisplayFeatureType.fold) && feature.bounds.height > feature.bounds.width;
    }).toList();

    var contentWidth = size.width;
    final foldable = verticalHinge.isNotEmpty;
    if (foldable) {
      final hinge = verticalHinge.first.bounds;
      final left = hinge.left;
      final right = size.width - hinge.right;
      if (left > 0 && right > 0) contentWidth = left < right ? left : right;
    }

    final phone = contentWidth < 600;
    final tablet = contentWidth >= 600 && contentWidth < 900;
    final largeTablet = contentWidth >= 900;
    final scale = contentWidth < 360 ? .90 : contentWidth < 480 ? .96 : contentWidth < 600 ? 1.00 : contentWidth < 900 ? 1.04 : 1.08;
    final padding = (16 * scale).clamp(12.0, 28.0).toDouble();
    final columns = contentWidth < 420 ? 1 : contentWidth < 700 ? 2 : contentWidth < 1050 ? 3 : 4;

    return ResponsiveInfo(
      size: size,
      contentWidth: contentWidth,
      isPhone: phone,
      isTablet: tablet,
      isLargeTablet: largeTablet,
      isFoldable: foldable,
      useRail: contentWidth >= 720 && !foldable,
      layoutScale: scale,
      pagePadding: padding,
      contentMaxWidth: largeTablet ? 1440 : 1100,
      gridColumns: columns,
    );
  }

  static ResponsiveInfo of(BuildContext context) => ResponsiveInfo.fromMediaQuery(MediaQuery.of(context));

  double spacing(double value) => value * layoutScale;
  double size(double value) => value * layoutScale;
}

class ResponsiveContent extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;

  const ResponsiveContent({super.key, required this.child, this.padding, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final info = ResponsiveInfo.of(context);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? info.contentMaxWidth),
        child: Padding(padding: padding ?? EdgeInsets.all(info.pagePadding), child: child),
      ),
    );
  }
}
