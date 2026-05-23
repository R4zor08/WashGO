import 'package:flutter/material.dart';

enum AppBreakpoint { compact, medium, expanded }

enum ContentSize { auth, standard, wide }

class ResponsiveLayout {
  ResponsiveLayout._();

  static const double compactMax = 600;
  static const double expandedMin = 840;

  static AppBreakpoint breakpointOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < compactMax) return AppBreakpoint.compact;
    if (width < expandedMin) return AppBreakpoint.medium;
    return AppBreakpoint.expanded;
  }

  static bool isExpanded(BuildContext context) =>
      breakpointOf(context) == AppBreakpoint.expanded;

  static bool isCompact(BuildContext context) =>
      breakpointOf(context) == AppBreakpoint.compact;

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 360) return 12;
    if (width < compactMax) return 16;
    if (width < expandedMin) return 20;
    return 24;
  }

  static double contentMaxWidth(BuildContext context, ContentSize size) {
    switch (size) {
      case ContentSize.auth:
        return 440;
      case ContentSize.standard:
        final bp = breakpointOf(context);
        if (bp == AppBreakpoint.compact) return double.infinity;
        if (bp == AppBreakpoint.medium) return 720;
        return 960;
      case ContentSize.wide:
        final bp = breakpointOf(context);
        if (bp == AppBreakpoint.compact) return double.infinity;
        return 960;
    }
  }

  static int gridCrossAxisCount(
    BuildContext context, {
    int compact = 2,
    int medium = 3,
    int expanded = 4,
  }) {
    switch (breakpointOf(context)) {
      case AppBreakpoint.compact:
        return compact;
      case AppBreakpoint.medium:
        return medium;
      case AppBreakpoint.expanded:
        return expanded;
    }
  }

  static double navigationBottomInset(BuildContext context) {
    if (isExpanded(context)) return 24;
    return 100;
  }

  static EdgeInsets screenPadding(BuildContext context) {
    final h = horizontalPadding(context);
    return EdgeInsets.fromLTRB(h, 16, h, navigationBottomInset(context));
  }

  static bool showBottomNavLabels(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 360;

  static double qrReceiptSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 360) return 140;
    return 168;
  }
}
