import 'package:flutter/material.dart';

class ProductDetailsPage extends StatelessWidget {
  final String productId;
  
  const ProductDetailsPage({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل المنتج')),
      body: Center(
        child: Text(
          'تفاصيل المنتج: $productId\n(قيد التطوير)',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}