import 'package:flutter/material.dart';

/// مؤشر تحميل مخصص وذكي
class LoadingIndicator extends StatefulWidget {
  final Color? color;
  final double size;
  final double strokeWidth;
  final LoadingType type;
  final Duration duration;

  const LoadingIndicator({
    super.key,
    this.color,
    this.size = 24.0,
    this.strokeWidth = 2.0,
    this.type = LoadingType.circular,
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with TickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).primaryColor;
    
    switch (widget.type) {
      case LoadingType.circular:
        return _buildCircularIndicator(color);
      case LoadingType.dots:
        return _buildDotsIndicator(color);
      case LoadingType.pulse:
        return _buildPulseIndicator(color);
      case LoadingType.wave:
        return _buildWaveIndicator(color);
    }
  }

  Widget _buildCircularIndicator(Color color) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CircularProgressIndicator(
        strokeWidth: widget.strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  Widget _buildDotsIndicator(Color color) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animationValue = (_animation.value - delay).clamp(0.0, 1.0);
            final scale = 0.5 + (0.5 * Curves.elasticOut.transform(animationValue));
            
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.size * 0.1),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size * 0.2,
                  height: widget.size * 0.2,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildPulseIndicator(Color color) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final scale = 0.8 + (0.4 * Curves.easeInOut.transform(_animation.value));
        final opacity = 1.0 - _animation.value;
        
        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: color.withOpacity(opacity),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaveIndicator(Color color) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final delay = index * 0.1;
            final animationValue = (_animation.value - delay).clamp(0.0, 1.0);
            final height = widget.size * (0.3 + 0.7 * Curves.easeInOut.transform(animationValue));
            
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.size * 0.05),
              child: Container(
                width: widget.size * 0.1,
                height: height,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(widget.size * 0.05),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

enum LoadingType {
  circular,
  dots,
  pulse,
  wave,
}

/// مؤشر تحميل للبيانات المعقدة
class SmartLoadingIndicator extends StatelessWidget {
  final String message;
  final double progress;
  final bool showProgress;
  final Color? color;

  const SmartLoadingIndicator({
    super.key,
    this.message = 'جاري التحميل...',
    this.progress = 0.0,
    this.showProgress = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = this.color ?? theme.primaryColor;

    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoadingIndicator(
                color: color,
                size: 32,
                type: LoadingType.circular,
              ),
              
              const SizedBox(height: 16),
              
              Text(
                message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              
              if (showProgress) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// مؤشر تحميل للصفحات الكاملة
class FullPageLoadingIndicator extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color? backgroundColor;

  const FullPageLoadingIndicator({
    super.key,
    this.title = 'جاري التحميل...',
    this.subtitle = 'يرجى الانتظار',
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingIndicator(
              color: theme.primaryColor,
              size: 48,
              type: LoadingType.pulse,
            ),
            
            const SizedBox(height: 24),
            
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}