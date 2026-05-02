import 'package:flutter/material.dart';
import 'package:truce/core/utils/theme.dart';
import 'package:truce/features/prices/domain/models.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailsPage extends StatelessWidget {
  final Product product;
  const ProductDetailsPage({super.key, required this.product});

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details | تفاصيل المنتج'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.white,
              child: product.imageUrl != null
                  ? Image.network(product.imageUrl!, fit: BoxFit.contain)
                  : const Icon(Icons.image_outlined, size: 100, color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nameEn,
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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
        ],
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
                if (price.discountInfo != null)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: TruceTheme.accentGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(price.discountInfo!, style: const TextStyle(color: TruceTheme.accentGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (price.previousPrice != null)
                Text(
                  'EGP ${price.previousPrice!.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough, fontSize: 12),
                ),
              Text(
                'EGP ${price.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: TruceTheme.accentGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: price.productUrl != null ? () => _launchUrl(price.productUrl!) : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              backgroundColor: TruceTheme.primary,
            ),
            child: const Text('Visit'),
          ),
        ],
      ),
    );
  }
}
