import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truce/core/utils/local_strings.dart';
import 'package:truce/core/utils/shimmer_loader.dart';
import 'package:truce/core/utils/theme.dart';
import 'package:truce/features/auth/presentation/auth_cubit.dart';
import 'package:truce/features/auth/presentation/auth_dialog.dart';
import 'package:truce/features/prices/domain/models.dart';
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
    const _SearchContent(),
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
    final locale = context.watch<SettingsCubit>().state.locale.languageCode;
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
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.grid_view_rounded), label: LocalStrings.get('live_deals', locale)),
            BottomNavigationBarItem(icon: const Icon(Icons.search), label: LocalStrings.get('search', locale)),
            BottomNavigationBarItem(icon: const Icon(Icons.local_offer), label: LocalStrings.get('coupons', locale)),
            BottomNavigationBarItem(icon: const Icon(Icons.settings), label: LocalStrings.get('settings', locale)),
          ],
          onTap: (index) => setState(() => _currentIndex = index),
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          child: _pages[_currentIndex],
        ),
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  @override
  void initState() {
    super.initState();
    final pricesCubit = context.read<PricesCubit>();
    if (pricesCubit.state is PricesInitial) {
      pricesCubit.loadDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsCubit>().state.locale.languageCode;
    return BlocBuilder<PricesCubit, PricesState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () => context.read<PricesCubit>().loadDashboard(),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: true,
                expandedHeight: 140,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [TruceTheme.primary, TruceTheme.primaryContainer],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/logo.png', height: 24),
                      const SizedBox(width: 8),
                      Text(
                        LocalStrings.get('app_title', locale),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  centerTitle: true,
                ),
                backgroundColor: TruceTheme.primary,
                elevation: 0,
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    locale == 'ar' ? 'اختر فئة' : 'Explore Categories',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: TruceTheme.primary),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              if (state is PricesLoading)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.1,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const ShimmerLoader(width: double.infinity, height: 120, borderRadius: 24),
                      childCount: 6,
                    ),
                  ),
                )
              else if (state is PricesLoaded)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.1,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final category = state.categories[index];
                        return Hero(
                          tag: 'category-${category.id}',
                          child: _CategoryCard(category: category, locale: locale),
                        );
                      },
                      childCount: state.categories.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final String locale;

  const _CategoryCard({required this.category, required this.locale});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.read<PricesCubit>().selectCategory(category.id);
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              pageBuilder: (context, animation, secondaryAnimation) => _CategoryProductsPage(category: category),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                var begin = const Offset(0.0, 1.0);
                var end = Offset.zero;
                var curve = Curves.ease;
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                return SlideTransition(position: animation.drive(tween), child: child);
              },
            ),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: TruceTheme.primary.withValues(alpha: 0.08), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TruceTheme.accentGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getIconForCategory(category.nameEn), color: TruceTheme.accentGreen, size: 32),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  locale == 'ar' ? category.nameAr : category.nameEn,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: TruceTheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForCategory(String name) {
    switch (name) {
      case 'Electronics & Tech': return Icons.devices_other_rounded;
      case 'Home Appliances': return Icons.kitchen_rounded;
      case 'Groceries & Food': return Icons.local_grocery_store_rounded;
      case 'Personal Care & Beauty': return Icons.auto_awesome_rounded;
      case 'Fashion & Clothing': return Icons.checkroom_rounded;
      case 'Home & Furniture': return Icons.chair_rounded;
      case 'Baby Products': return Icons.child_friendly_rounded;
      case 'Tools & Hardware': return Icons.handyman_rounded;
      case 'Automotive': return Icons.directions_car_filled_rounded;
      case 'Pet Supplies': return Icons.pets_rounded;
      default: return Icons.category_rounded;
    }
  }
}

class _CategoryProductsPage extends StatelessWidget {
  final Category category;
  const _CategoryProductsPage({required this.category});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsCubit>().state.locale.languageCode;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text(locale == 'ar' ? category.nameAr : category.nameEn, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: TruceTheme.primary,
      ),
      body: BlocBuilder<PricesCubit, PricesState>(
        builder: (context, state) {
          if (state is PricesLoading) {
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: 8,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: ShimmerLoader(width: double.infinity, height: 120, borderRadius: 20),
              ),
            );
          } else if (state is PricesLoaded) {
            final products = state.products;
            if (products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    Text(
                      locale == 'ar' ? 'لا توجد منتجات حالياً' : 'No products found here',
                      style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 400 + (index * 60)),
                  curve: Curves.easeOutQuart,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: _SearchProductTile(product: p, locale: locale),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _SearchContent extends StatelessWidget {
  const _SearchContent();

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsCubit>().state.locale.languageCode;
    return BlocBuilder<PricesCubit, PricesState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: AppBar(
            title: Text(LocalStrings.get('search', locale), style: const TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: TruceTheme.primary,
            elevation: 0,
          ),
          body: Column(
            children: [
               Container(
                 color: Colors.white,
                 padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                 child: SearchBar(
                   hintText: LocalStrings.get('search_hint', locale),
                   onSubmitted: (q) => context.read<PricesCubit>().searchProducts(q),
                   elevation: WidgetStateProperty.all(0),
                   backgroundColor: WidgetStateProperty.all(Colors.grey[100]),
                   padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16)),
                   shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                 ),
               ),
              if (state is PricesLoading)
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: 8,
                    itemBuilder: (context, index) => const Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: ShimmerLoader(width: double.infinity, height: 120, borderRadius: 20),
                    ),
                  ),
                )
              else if (state is PricesLoaded)
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      final p = state.products[index];
                      return _SearchProductTile(product: p, locale: locale);
                    },
                  ),
                ),
            ],
          ),
        );
      }
    );
  }
}

class _SearchProductTile extends StatelessWidget {
  final Product product;
  final String locale;

  const _SearchProductTile({required this.product, required this.locale});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailsPage(product: product))),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 90,
                height: 90,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: product.imageUrl != null
                  ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => const Icon(Icons.broken_image_rounded, color: Colors.grey, size: 30),
                    )
                  : const Icon(Icons.image_rounded, color: Colors.grey, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale == 'ar' ? product.nameAr : product.nameEn,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: TruceTheme.primary),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'EGP ${product.prices.first.price}',
                          style: const TextStyle(color: TruceTheme.accentGreen, fontWeight: FontWeight.w800, fontSize: 18),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: TruceTheme.accentGreen.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.prices.first.storeNameEn,
                            style: const TextStyle(color: TruceTheme.accentGreen, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
