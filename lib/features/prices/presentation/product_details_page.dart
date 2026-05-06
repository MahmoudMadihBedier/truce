import 'package:flutter/material.dart';
import 'package:truce/core/utils/shimmer_loader.dart';
import 'package:truce/core/utils/theme.dart';
import 'package:truce/features/prices/domain/models.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailsPage extends StatelessWidget {
  final Product product;
  const ProductDetailsPage({super.key, required this.product});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Market View'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.white,
              child: Center(
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                   ? Image.network(
                       product.imageUrl!,
                       fit: BoxFit.contain,
                       loadingBuilder: (context, child, progress) {
                         if (progress == null) return child;
                         return const Center(child: ShimmerLoader(width: 200, height: 200));
                       },
                       errorBuilder: (c, e, s) => const Icon(Icons.broken_image_outlined, size: 100, color: Colors.grey),
                     )
                   : const Icon(Icons.image_outlined, size: 100, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nameEn,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: TruceTheme.primary),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.compare_arrows, color: TruceTheme.accentGreen),
                      const SizedBox(width: 8),
                      Text(
                        'Live Comparison (${product.prices.length} Stores)',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TruceTheme.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (product.prices.isEmpty)
                    const Center(child: Text('Live search currently analyzing prices...'))
                  else
                    ...product.prices.map((p) => _buildStorePriceTile(context, p)),
                  const SizedBox(height: 24),
                  if (product.descriptionEn != null) ...[
                    const Text(
                      'Details',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TruceTheme.primary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.descriptionEn!,
                      style: TextStyle(color: Colors.grey[700], height: 1.6, fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorePriceTile(BuildContext context, ProductPrice price) {
    final isLowest = price == product.prices.first;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isLowest ? TruceTheme.accentGreen : Colors.grey.withOpacity(0.2)),
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: TruceTheme.primary),
                ),
                if (price.location != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(price.location!, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(price.storeRating.toStringAsFixed(1), style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'EGP ${price.price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isLowest ? TruceTheme.accentGreen : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 19
                ),
              ),
              if (price.mrp > price.price)
                Text(
                  'EGP ${price.mrp.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough, fontSize: 12),
                ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: (price.productUrl != null && price.productUrl!.isNotEmpty)
                  ? () => _launchUrl(price.productUrl!)
                  : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLowest ? TruceTheme.accentGreen : TruceTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  minimumSize: const Size(100, 32),
                ),
                child: const Text('Visit Store'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
