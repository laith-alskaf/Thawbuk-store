import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_outline, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('المفضلة', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('قيد التطوير', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}