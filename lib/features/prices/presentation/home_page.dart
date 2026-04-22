import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truce/core/utils/local_strings.dart';
import 'package:truce/core/utils/marquee_ticker.dart';
import 'package:truce/core/utils/theme.dart';
import 'package:truce/features/auth/presentation/auth_cubit.dart';
import 'package:truce/features/auth/presentation/auth_dialog.dart';
import 'package:truce/features/prices/domain/models.dart';
import 'package:truce/features/prices/presentation/market_rates_page.dart';
import 'package:truce/features/prices/presentation/prices_cubit.dart';
import 'package:truce/features/prices/presentation/product_details_page.dart';
import 'package:truce/features/settings/presentation/settings_cubit.dart';
import 'package:truce/features/settings/presentation/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _HomeContent(),
    const Center(child: Text('Search - Coming Soon')),
    const Center(child: Text('Coupons - Coming Soon')),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndShowPopup();
    });
  }

  void _checkAuthAndShowPopup() {
    final authCubit = context.read<AuthCubit>();
    if (authCubit.state is AuthUnauthenticated || authCubit.state is AuthInitial) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AuthDialog(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: TruceTheme.accentGreen,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: 'Coupons'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
      body: _pages[_currentIndex],
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsCubit>().state.locale.languageCode;
    return BlocBuilder<PricesCubit, PricesState>(
      builder: (context, state) {
        if (state is PricesInitial) {
          context.read<PricesCubit>().loadDashboard();
          return const Center(child: CircularProgressIndicator());
        }
        if (state is PricesLoading) return const Center(child: CircularProgressIndicator());
        if (state is PricesError) return Center(child: Text(state.message));
        if (state is PricesLoaded) {
          return RefreshIndicator(
            onRefresh: () => context.read<PricesCubit>().loadDashboard(),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  title: Text(LocalStrings.get('app_title', locale)),
                ),
                SliverToBoxAdapter(
                  child: MarqueeTicker(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MarketRatesPage())),
                    children: [
                      for (var c in state.currencyRates)
                        Text(
                          '${LocalStrings.get('usd_egp', locale)}: ${c.rateToEgp}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      for (var g in state.goldPrices)
                        Text(
                          '${LocalStrings.get('gold', locale)} ${g.carat}: ${g.sell} EGP',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SearchBar(
                      hintText: LocalStrings.get('search_hint', locale),
                      leading: const Icon(Icons.search),
                      onSubmitted: (query) => context.read<PricesCubit>().searchProducts(query),
                      elevation: WidgetStateProperty.all(0),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      LocalStrings.get('market_products', locale),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = state.products[index];
                      return _buildProductCard(context, product, locale);
                    },
                    childCount: state.products.length,
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Product product, String locale) {
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: product.imageUrl != null
                    ? Image.network(product.imageUrl!, fit: BoxFit.contain)
                    : const Icon(Icons.image_outlined, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale == 'ar' ? product.nameAr : product.nameEn,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (lowestPrice != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${LocalStrings.get('lowest', locale)}: EGP ${lowestPrice.price}',
                        style: const TextStyle(color: TruceTheme.accentGreen, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${LocalStrings.get('at', locale)} ${locale == 'ar' ? lowestPrice.storeNameAr : lowestPrice.storeNameEn}',
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
