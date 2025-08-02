import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingText;
  final Color? backgroundColor;
  final Color? indicatorColor;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingText,
    this.backgroundColor,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withOpacity(0.3),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        indicatorColor ?? AppColors.primary,
                      ),
                    ),
                    if (loadingText != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        loadingText!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Widget بسيط لمؤشر التحميل
class SimpleLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double size;
  final double strokeWidth;

  const SimpleLoadingIndicator({
    super.key,
    this.color,
    this.size = 24,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primary,
        ),
      ),
    );
  }
}

// Widget لحالة التحميل مع نص
class LoadingWidget extends StatelessWidget {
  final String? text;
  final Color? color;
  final double spacing;

  const LoadingWidget({
    super.key,
    this.text,
    this.color,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SimpleLoadingIndicator(color: color),
        if (text != null) ...[
          SizedBox(height: spacing),
          Text(
            text!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color ?? AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

// Widget لحالة التحميل في الصفحة كاملة
class FullPageLoading extends StatelessWidget {
  final String? text;
  final Color? backgroundColor;

  const FullPageLoading({
    super.key,
    this.text,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      body: Center(
        child: LoadingWidget(text: text),
      ),
    );
  }
}