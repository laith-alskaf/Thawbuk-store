import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonColor = backgroundColor ?? AppColors.primary;
    final buttonTextColor = textColor ?? 
        (isOutlined ? buttonColor : AppColors.white);

    return SizedBox(
      width: width,
      height: height ?? 48,
      child: isOutlined
          ? OutlinedButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon: isLoading 
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(buttonTextColor),
                      ),
                    )
                  : icon != null 
                      ? Icon(icon, size: 18) 
                      : const SizedBox.shrink(),
              label: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: buttonTextColor,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: buttonTextColor,
                side: BorderSide(color: buttonColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          : ElevatedButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon: isLoading 
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(buttonTextColor),
                      ),
                    )
                  : icon != null 
                      ? Icon(icon, size: 18) 
                      : const SizedBox.shrink(),
              label: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: buttonTextColor,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: buttonTextColor,
                disabledBackgroundColor: buttonColor.withOpacity(0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
    );
  }
}