import 'package:flutter/material.dart';
import 'package:washgo/core/layout/responsive_layout.dart';

class ResponsiveContent extends StatelessWidget {
  final Widget child;
  final ContentSize size;
  final EdgeInsetsGeometry? padding;
  final bool alignTop;

  const ResponsiveContent({
    super.key,
    required this.child,
    this.size = ContentSize.standard,
    this.padding,
    this.alignTop = false,
  });

  const ResponsiveContent.auth({
    super.key,
    required this.child,
    this.padding,
    this.alignTop = false,
  }) : size = ContentSize.auth;

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveLayout.contentMaxWidth(context, size);
    final hPad = ResponsiveLayout.horizontalPadding(context);

    Widget content = Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: hPad),
      child: child,
    );

    if (maxWidth.isFinite) {
      content = Align(
        alignment: alignTop ? Alignment.topCenter : Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: content,
        ),
      );
    }

    return content;
  }
}
