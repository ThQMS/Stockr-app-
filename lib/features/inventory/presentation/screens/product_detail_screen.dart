import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({
    required this.productId,
    super.key,
  });

  final String productId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Detalhes do produto: $productId'),
      ),
    );
  }
}
