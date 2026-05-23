import 'package:flutter/material.dart';
import 'package:washgo/core/constants/app_colors.dart';
import 'package:washgo/core/constants/app_text_styles.dart';

enum CustomButtonStyle { primary, secondary }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final CustomButtonStyle style;
  final double? width;
  final bool compact;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.style = CustomButtonStyle.primary,
    this.width,
    this.compact = false,
  });

  double get _height => compact ? 46 : 52;

  ButtonStyle get _baseButtonStyle => ButtonStyle(
        minimumSize: WidgetStateProperty.all(Size.zero),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(horizontal: compact ? 10 : 16, vertical: compact ? 10 : 14),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final isPrimary = style == CustomButtonStyle.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedWidth = width ??
            (constraints.hasBoundedWidth && constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : null);

        return SizedBox(
          width: resolvedWidth,
          height: _height,
          child: isPrimary ? _buildPrimary() : _buildSecondary(),
        );
      },
    );
  }

  Widget _buildPrimary() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: compact ? null : AppColors.glowShadow(),
      ),
      child: SizedBox(
        width: double.infinity,
        height: _height,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: _baseButtonStyle.copyWith(
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
            shadowColor: WidgetStateProperty.all(Colors.transparent),
          ),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildSecondary() {
    return SizedBox(
      width: double.infinity,
      height: _height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: _baseButtonStyle.copyWith(
          foregroundColor: WidgetStateProperty.all(AppColors.aquaBlue),
          side: const WidgetStatePropertyAll(BorderSide(color: AppColors.aquaBlue)),
        ),
        child: _buildContent(color: AppColors.aquaBlue),
      ),
    );
  }

  Widget _buildContent({Color? color}) {
    final contentColor = color ?? AppColors.textLight;
    final textStyle = AppTextStyles.button.copyWith(
      color: contentColor,
      fontSize: compact ? 14 : 16,
    );
    final iconSize = compact ? 18.0 : 20.0;

    if (isLoading) {
      return SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: contentColor,
        ),
      );
    }

    if (icon != null) {
      return SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize, color: contentColor),
            SizedBox(width: compact ? 4 : 8),
            Flexible(
              child: Text(
                text,
                style: textStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return Text(
      text,
      style: textStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }
}
