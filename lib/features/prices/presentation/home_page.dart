import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truce/core/utils/theme.dart';
import 'package:truce/features/prices/domain/models.dart';
import 'package:truce/features/prices/presentation/prices_cubit.dart';
import 'package:truce/features/prices/presentation/product_details_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: TruceTheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: 'Coupons'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: BlocBuilder<PricesCubit, PricesState>(
        builder: (context, state) {
          if (state is PricesInitial) {
            context.read<PricesCubit>().loadDashboard();
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PricesLoading) return const Center(child: CircularProgressIndicator());
          if (state is PricesError) return Center(child: Text(state.message));
          if (state is PricesLoaded) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 120,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text('Truce Egypt', style: TextStyle(color: TruceTheme.primary)),
                    background: Container(color: TruceTheme.background),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildPriceTicker(state.goldPrices, state.currencyRates),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SearchBar(
                      hintText: 'Search products... | ابحث عن المنتجات',
                      leading: const Icon(Icons.search),
                      elevation: WidgetStateProperty.all(0),
                      backgroundColor: WidgetStateProperty.all(Colors.white),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'Price Drops | انخفاض الأسعار',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: TruceTheme.primary),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = state.products[index];
                      return _buildProductCard(context, product);
                    },
                    childCount: state.products.length,
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildPriceTicker(List<GoldPrice> gold, List<CurrencyRate> currency) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: TruceTheme.primary,
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (var g in gold)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Gold ${g.carat}: ${g.sell} EGP',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          for (var c in currency)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                '${c.code}/EGP: ${c.rateToEgp}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    final lowestPrice = product.prices.isNotEmpty ? product.prices.first : null;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProductDetailsPage(product: product)),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image_outlined, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${product.nameEn} | ${product.nameAr}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (lowestPrice != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Lowest: EGP ${lowestPrice.price}',
                        style: const TextStyle(color: TruceTheme.accentGreen, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'at ${lowestPrice.storeNameEn}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ] else
                      const Text('No price available', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
