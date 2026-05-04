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
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback for some devices where canLaunchUrl is strict
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
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
              height: 300,
              width: double.infinity,
              color: Colors.white,
              child: Stack(
                children: [
                   Center(
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
                   if (product.prices.isNotEmpty && product.prices.first.discountInfo != null)
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            product.prices.first.discountInfo!,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                ],
              ),
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
                  const SizedBox(height: 12),
                  if (product.descriptionEn != null) ...[
                    const Text(
                      'Description | الوصف',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TruceTheme.primary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.descriptionEn!,
                      style: TextStyle(color: Colors.grey[700], height: 1.5),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text(
                    'Best Offer | أفضل عرض',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TruceTheme.primary),
                  ),
                  const SizedBox(height: 12),
                  if (product.prices.isEmpty)
                    const Center(child: Text('Price Currently N/A'))
                  else
                    ...product.prices.map((p) => _buildStorePriceTile(context, p)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorePriceTile(BuildContext context, ProductPrice price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: TruceTheme.primary),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      price.storeRating.toString(),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      price.isAvailable ? 'In Stock' : 'Out of Stock',
                      style: TextStyle(
                        color: price.isAvailable ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
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
                  style: const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough, fontSize: 14),
                ),
              Text(
                'EGP ${price.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: TruceTheme.accentGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: (price.productUrl != null && price.productUrl!.isNotEmpty)
                  ? () => _launchUrl(price.productUrl!)
                  : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TruceTheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(100, 36),
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
