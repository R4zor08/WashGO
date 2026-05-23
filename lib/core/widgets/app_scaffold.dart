import 'package:flutter/material.dart';
import 'package:washgo/core/constants/app_colors.dart';
import 'package:washgo/core/layout/responsive_layout.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final bool extendBody;
  final EdgeInsetsGeometry? padding;
  final bool useResponsivePadding;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.extendBody = false,
    this.padding,
    this.useResponsivePadding = false,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedPadding = padding ??
        (useResponsivePadding
            ? EdgeInsets.symmetric(horizontal: ResponsiveLayout.horizontalPadding(context))
            : const EdgeInsets.symmetric(horizontal: 16));

    return Scaffold(
      extendBody: extendBody,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.screenBackgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: resolvedPadding,
            child: body,
          ),
        ),
      ),
    );
  }
}

class WashGoLogo extends StatelessWidget {
  final double height;
  final bool showGlow;

  const WashGoLogo({super.key, this.height = 100, this.showGlow = false});

  @override
  Widget build(BuildContext context) {
    Widget logo = Image.asset(
      'assets/images/logo.png',
      height: height,
      fit: BoxFit.contain,
    );

    if (showGlow) {
      logo = Container(
        decoration: BoxDecoration(
          boxShadow: AppColors.glowShadow(blur: 30),
        ),
        child: logo,
      );
    }

    return logo;
  }
}
