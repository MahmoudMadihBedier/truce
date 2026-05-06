import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truce/core/utils/local_strings.dart';
import 'package:truce/core/utils/marquee_ticker.dart';
import 'package:truce/core/utils/shimmer_loader.dart';
import 'package:truce/core/utils/theme.dart';
import 'package:truce/features/auth/presentation/auth_cubit.dart';
import 'package:truce/features/auth/presentation/auth_dialog.dart';
import 'package:truce/features/prices/domain/models.dart';
import 'package:truce/features/prices/presentation/market_rates_page.dart';
import 'package:truce/features/prices/presentation/prices_cubit.dart';
import 'package:truce/features/prices/presentation/product_details_page.dart';
import 'package:truce/features/settings/presentation/settings_cubit.dart';
import 'package:truce/features/settings/presentation/settings_page.dart';
import 'package:truce/features/coupons/presentation/coupons_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _HomeContent(),
    const Center(child: Text('Live Egypt Search')),
    const CouponsPage(),
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
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated || state is AuthGuest) {
          context.read<PricesCubit>().loadDashboard();
        }
      },
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: TruceTheme.accentGreen,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.flash_on), label: 'Live Deals'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: 'Coupons'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
          onTap: (index) => setState(() => _currentIndex = index),
        ),
        body: _pages[_currentIndex],
      ),
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
        }

        return RefreshIndicator(
          onRefresh: () => context.read<PricesCubit>().loadDashboard(
            categoryId: state is PricesLoaded ? state.selectedCategoryId : null
          ),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: true,
                title: Row(
                  children: [
                    Image.asset('assets/images/logo.png', height: 38),
                    const SizedBox(width: 10),
                    Text(LocalStrings.get('app_title', locale), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              if (state is PricesLoaded)
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
                          '${LocalStrings.get('gold', locale)} ${g.carat}: ${g.sell.toStringAsFixed(2)} EGP',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                    ],
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: SearchBar(
                    hintText: "Live Market Search (Jumia, Amazon...)",
                    leading: const Icon(Icons.search),
                    trailing: [
                       if (state is PricesLoading)
                         const Padding(
                           padding: EdgeInsets.only(right: 8.0),
                           child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: TruceTheme.accentGreen)),
                         )
                    ],
                    onSubmitted: (query) => context.read<PricesCubit>().searchProducts(query),
                    elevation: WidgetStateProperty.all(0),
                    backgroundColor: WidgetStateProperty.all(Colors.grey[200]),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ),
              if (state is PricesLoaded)
                SliverToBoxAdapter(
                  child: Container(
                    height: 50,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.categories.length + 1,
                      itemBuilder: (context, index) {
                        final isAll = index == 0;
                        final isSelected = isAll ? state.selectedCategoryId == null : state.selectedCategoryId == state.categories[index - 1].id;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(isAll ? 'Egypt Deals' : (locale == 'ar' ? state.categories[index - 1].nameAr : state.categories[index - 1].nameEn)),
                            selected: isSelected,
                            onSelected: (_) => context.read<PricesCubit>().selectCategory(isAll ? null : state.categories[index - 1].id),
                            selectedColor: TruceTheme.accentGreen.withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: isSelected ? TruceTheme.accentGreen : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      const Icon(Icons.live_tv_rounded, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        "Live Accuracy Hub",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              if (state is PricesLoading)
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.62,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const ShimmerLoader(width: 200, height: 260, borderRadius: 16),
                      childCount: 6,
                    ),
                  ),
                )
              else if (state is PricesLoaded)
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.62,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = state.products[index];
                        return _buildProductCard(context, product, locale);
                      },
                      childCount: state.products.length,
                    ),
                  ),
                ),
            ],
          ),
        );
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
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                ),
                child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(child: ShimmerLoader(width: 60, height: 60));
                        },
                        errorBuilder: (c, e, s) => const Icon(Icons.broken_image_outlined, color: Colors.grey),
                      )
                    : const Icon(Icons.image_outlined, color: Colors.grey, size: 40),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.nameEn,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (lowestPrice != null) ...[
                      Text(
                        'EGP ${lowestPrice.price.toStringAsFixed(2)}',
                        style: const TextStyle(color: TruceTheme.accentGreen, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.storefront_outlined, size: 10, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              lowestPrice.storeNameEn,
                              style: TextStyle(color: Colors.grey[600], fontSize: 9),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (product.prices.length > 1)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            '+${product.prices.length - 1} OTHER STORES',
                            style: const TextStyle(color: Colors.orange, fontSize: 7, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
