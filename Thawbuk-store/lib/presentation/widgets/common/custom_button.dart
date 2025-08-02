import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum ButtonType { primary, secondary, outline, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isExpanded;
  final IconData? icon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double borderRadius;
  final double elevation;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isExpanded = true,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.fontSize,
    this.fontWeight,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius = 12,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    Widget button;

    switch (type) {
      case ButtonType.primary:
        button = _buildElevatedButton(context);
        break;
      case ButtonType.secondary:
        button = _buildFilledButton(context);
        break;
      case ButtonType.outline:
        button = _buildOutlinedButton(context);
        break;
      case ButtonType.text:
        button = _buildTextButton(context);
        break;
    }

    if (width != null || !isExpanded) {
      return SizedBox(
        width: width,
        height: height ?? 48,
        child: button,
      );
    }

    return SizedBox(
      width: double.infinity,
      height: height ?? 48,
      child: button,
    );
  }

  Widget _buildElevatedButton(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: foregroundColor ?? AppColors.onPrimary,
        elevation: elevation,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
      ),
      child: _buildButtonContent(context),
    );
  }

  Widget _buildFilledButton(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.secondary,
        foregroundColor: foregroundColor ?? AppColors.onSecondary,
        elevation: elevation,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
      ),
      child: _buildButtonContent(context),
    );
  }

  Widget _buildOutlinedButton(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor ?? AppColors.primary,
        side: BorderSide(
          color: borderColor ?? AppColors.primary,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
      ),
      child: _buildButtonContent(context),
    );
  }

  Widget _buildTextButton(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: foregroundColor ?? AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
      ),
      child: _buildButtonContent(context),
    );
  }

  Widget _buildButtonContent(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == ButtonType.primary
                ? AppColors.onPrimary
                : type == ButtonType.secondary
                    ? AppColors.onSecondary
                    : AppColors.primary,
          ),
        ),
      );
    }

    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: fontSize ?? 16,
          fontWeight: fontWeight ?? FontWeight.w600,
        );

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text, style: textStyle),
        ],
      );
    }

    return Text(text, style: textStyle);
  }
}

// أزرار مخصصة للاستخدامات الشائعة
class PrimaryButton extends CustomButton {
  const PrimaryButton({
    super.key,
    required super.text,
    super.onPressed,
    super.isLoading = false,
    super.icon,
  }) : super(type: ButtonType.primary);
}

class SecondaryButton extends CustomButton {
  const SecondaryButton({
    super.key,
    required super.text,
    super.onPressed,
    super.isLoading = false,
    super.icon,
  }) : super(type: ButtonType.secondary);
}

class OutlineButton extends CustomButton {
  const OutlineButton({
    super.key,
    required super.text,
    super.onPressed,
    super.isLoading = false,
    super.icon,
  }) : super(type: ButtonType.outline);
}

class TextOnlyButton extends CustomButton {
  const TextOnlyButton({
    super.key,
    required super.text,
    super.onPressed,
    super.isLoading = false,
    super.icon,
  }) : super(type: ButtonType.text);
}