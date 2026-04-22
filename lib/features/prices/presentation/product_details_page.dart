import 'package:flutter/material.dart';
import 'package:truce/core/utils/theme.dart';
import 'package:truce/features/prices/domain/models.dart';

class ProductDetailsPage extends StatelessWidget {
  final Product product;
  const ProductDetailsPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details | تفاصيل المنتج'),
        leading: const BackButton(color: TruceTheme.primary),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.white,
              child: const Icon(Icons.image_outlined, size: 100, color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${product.nameEn} | ${product.nameAr}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: TruceTheme.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.descriptionEn ?? 'No description available.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Price Comparison | مقارنة الأسعار',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TruceTheme.primary),
                  ),
                  const SizedBox(height: 12),
                  ...product.prices.map((p) => _buildStorePriceTile(p)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorePriceTile(ProductPrice price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  price.storeNameEn,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text('${price.storeRating}', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'EGP ${price.price}',
                style: const TextStyle(
                  color: TruceTheme.accentGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Text('Available', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('View'),
          ),
        ],
      ),
    );
  }
}
