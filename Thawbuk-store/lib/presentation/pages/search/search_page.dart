import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('البحث'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_outlined, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('البحث', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('قيد التطوير', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}