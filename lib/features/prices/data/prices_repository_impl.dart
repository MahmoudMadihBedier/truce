import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truce/core/error/failures.dart';
import 'package:truce/core/utils/typedefs.dart';
import 'package:truce/features/prices/domain/models.dart';
import 'package:truce/features/prices/domain/prices_repository.dart';

class PricesRepositoryImpl implements PricesRepository {
  final SupabaseClient _client;
  final http.Client _httpClient = http.Client();

  PricesRepositoryImpl(this._client);

  @override
  Future<ApiResult<List<Product>>> getProducts({String? query, int? categoryId}) async {
    try {
      List<Product> allProducts = [];

      // 1. Add User Provided Mock Data (Jumia & Carrefour)
      allProducts.addAll(_getUserMockProducts());

      // 2. Fetch from GS1 Egypt API (Mock)
      try {
        final gs1Response = await _httpClient.get(
          Uri.parse('http://private-anon-b59c34f288-gs1egyptproducts.apiary-mock.com/products'),
        ).timeout(const Duration(seconds: 10));

        if (gs1Response.statusCode == 200) {
          final gs1Data = json.decode(gs1Response.body);
          if (gs1Data is Map && gs1Data.containsKey('products')) {
            final gs1Products = gs1Data['products'] as List<dynamic>;

            allProducts.addAll(gs1Products.map((item) {
              final productName = item['productName']?['value'] ?? 'Unknown Product';
              final description = item['consumerMarketingDescription']?['value'];
              final photos = item['photos']?['value'];
              final imageUrl = (photos is List && photos.isNotEmpty) ? photos[0] : null;

              final random = Random();
              final basePrice = 20.0 + random.nextInt(100);

              return Product(
                id: random.nextInt(100000),
                nameEn: productName,
                nameAr: productName,
                descriptionEn: description,
                descriptionAr: description,
                imageUrl: imageUrl,
                prices: [
                  ProductPrice(
                    id: 1,
                    price: basePrice,
                    storeNameEn: 'Amazon Egypt',
                    storeNameAr: 'أمازون مصر',
                    storeRating: 4.5,
                    isAvailable: true,
                  ),
                  ProductPrice(
                    id: 2,
                    price: max(5.0, basePrice - 2.5),
                    storeNameEn: 'Noon',
                    storeNameAr: 'نون',
                    storeRating: 4.2,
                    isAvailable: true,
                  ),
                ]..sort((a, b) => a.price.compareTo(b.price)),
              );
            }));
          }
        }
      } catch (e) {
        // Silently fail for mock APIs
      }

      // 3. Fetch from Supabase (Live Dashboard Data)
      try {
        final supabaseResponse = await _client.from('products').select('''
          *,
          product_prices (
            price,
            is_available,
            stores (
              name_en,
              name_ar,
              rating
            )
          )
        ''');

        final supabaseData = supabaseResponse as List<dynamic>;

        allProducts.addAll(supabaseData.map((item) {
          final product = Product.fromJson(item);
          final pricesList = (item['product_prices'] as List<dynamic>).map((p) {
            final store = p['stores'];
            return ProductPrice(
              id: 0,
              price: (p['price'] as num).toDouble(),
              storeNameEn: store['name_en'] ?? 'Unknown',
              storeNameAr: store['name_ar'] ?? 'غير معروف',
              storeRating: (store['rating'] as num? ?? 0.0).toDouble(),
              isAvailable: p['is_available'] ?? true,
            );
          }).toList();

          pricesList.sort((a, b) => a.price.compareTo(b.price));

          return Product(
            id: product.id,
            nameEn: product.nameEn,
            nameAr: product.nameAr,
            descriptionEn: product.descriptionEn,
            descriptionAr: product.descriptionAr,
            imageUrl: product.imageUrl,
            prices: pricesList,
          );
        }));
      } catch (e) {
        // Supabase error handling
      }

      // Filter by query if provided
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        allProducts = allProducts.where((p) =>
          p.nameEn.toLowerCase().contains(q) ||
          p.nameAr.toLowerCase().contains(q) ||
          (p.descriptionEn?.toLowerCase().contains(q) ?? false)
        ).toList();
      }

      return (null, allProducts);
    } catch (e) {
      return (ServerFailure('Failed to fetch products: ${e.toString()}'), null);
    }
  }

  List<Product> _getUserMockProducts() {
    final List<Map<String, dynamic>> rawData = [
      {
        "Sr No": 1,
        "Product URL": "https://www.jumia.com.eg/lavazza-decaffeinated-ground-coffee-classico-medium-roast-250-g-133683707.html",
        "Product ID": 133683707,
        "Product Name": "Decaffeinated Ground Coffee Classico - Medium Roast - 250 g",
        "Category": "Home | Supermarket | Beverages | Coffee, Tea & Cocoa | Coffee | Bottled & Canned Coffee Drinks | Decaffeinated Ground Coffee | Classico - Medium Roast - 250 g",
        "Brand": "lavazza",
        "MRP (EGP)": 700,
        "Discount %": 29,
        "Price": 500,
        "Description": "Discover real Italian coffee in all its forms. Dek Classico, the ideal coffee blend for when you want to enjoy some authentic Italian coffee, without all the caffeine.",
        "Product Image URL": "https://eg.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/70/7386331/1.jpg?5099",
        "Store": "Jumia"
      },
      {
        "Sr No": 6,
        "Product URL": "https://www.jumia.com.eg/sokany-corded-lint-remover-sk-877-51998016.html",
        "Product ID": 51998016,
        "Product Name": "Sokany Corded Lint Remover SK-877",
        "Brand": "sokany",
        "MRP (EGP)": 399,
        "Discount %": 48,
        "Price": 209,
        "Description": "Sokany Corded Lint Remover SK-877 is your go-to solution for restoring the elegant look of your garments.",
        "Product Image URL": "https://eg.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/61/089915/1.jpg?4516",
        "Store": "Jumia"
      },
      {
        "Sr No": 1,
        "Product URL": "https://www.carrefouregypt.com/mafegy/en/energy-drinks/redbull-energy-drink-250m-4/p/294682?offer=offer_carrefour_&sid=SLOTTED&sellerId=0000",
        "Product ID": 294682,
        "Product Name": "Red Bull Energy Drink - 250ml - 4 Packs",
        "Brand": "Red Bull",
        "MRP (EGP)": 219.95,
        "Discount %": 7,
        "Price": 204.99,
        "Description": "An energy drink enhanced with caffeine and vitamins, perfect for maintaining alertness and energy.",
        "Product Image URL": "https://cdn.mafrservices.com/pim-content/EGY/media/product/294682/1757842205/294682_main.jpg?im=Resize=58",
        "Store": "Carrefour"
      },
      {
        "Sr No": 10,
        "Product ID": 657524,
        "Product Name": "Ariel Downy Power Gel Laundry Detergent - 3 Liter",
        "Brand": "Ariel",
        "MRP (EGP)": 340,
        "Discount %": 22,
        "Price": 264.99,
        "Description": "This Gel is the first solution for your clothes. Gentle on fabrics, it offers strong stain removal.",
        "Product Image URL": "https://cdn.mafrservices.com/pim-content/EGY/media/product/657524/1757327405/657524_main.jpg?im=Resize=58",
        "Store": "Carrefour"
      }
    ];

    return rawData.map((item) {
      double? price;
      if (item['Price'] != "N/A" && item['Price'] != null) {
        price = (item['Price'] as num).toDouble();
      }

      double? mrp;
      if (item['MRP (EGP)'] != "N/A" && item['MRP (EGP)'] != null) {
        mrp = (item['MRP (EGP)'] as num).toDouble();
      }

      String? discount;
      if (item['Discount %'] != "N/A" && item['Discount %'] != null) {
        discount = "${item['Discount %']}% OFF";
      }

      return Product(
        id: item['Product ID'],
        nameEn: item['Product Name'],
        nameAr: item['Product Name'],
        descriptionEn: item['Description'],
        descriptionAr: item['Description'],
        imageUrl: item['Product Image URL'],
        prices: [
          if (price != null)
            ProductPrice(
              id: item['Sr No'],
              price: price,
              previousPrice: mrp,
              storeNameEn: item['Store'],
              storeNameAr: item['Store'] == 'Jumia' ? 'جوميا' : 'كارفور',
              storeRating: 4.5,
              isAvailable: true,
              productUrl: item['Product URL'],
              discountInfo: discount,
            )
        ],
      );
    }).toList();
  }

  @override
  Future<ApiResult<List<GoldPrice>>> getGoldPrices() async {
    try {
      final response = await _client.from('gold_prices').select();
      final data = response as List<dynamic>;
      if (data.isNotEmpty) {
        return (null, data.map((g) => GoldPrice(
          carat: g['carat'],
          buy: (g['price_buy'] as num).toDouble(),
          sell: (g['price_sell'] as num).toDouble(),
          updatedAt: DateTime.parse(g['updated_at']),
        )).toList());
      }
    } catch (e) { }

    return (null, [
      GoldPrice(carat: '24K', buy: 4200, sell: 4250, updatedAt: DateTime.now()),
      GoldPrice(carat: '21K', buy: 3675, sell: 3720, updatedAt: DateTime.now()),
      GoldPrice(carat: '18K', buy: 3150, sell: 3190, updatedAt: DateTime.now()),
    ]);
  }

  @override
  Future<ApiResult<List<CurrencyRate>>> getCurrencyRates() async {
    try {
      final response = await _client.from('currency_rates').select();
      final data = response as List<dynamic>;
      if (data.isNotEmpty) {
        return (null, data.map((c) => CurrencyRate(
          code: c['currency_code'],
          rateToEgp: (c['rate_to_egp'] as num).toDouble(),
          updatedAt: DateTime.parse(c['updated_at']),
        )).toList());
      }
    } catch (e) { }

    return (null, [
      CurrencyRate(code: 'USD', rateToEgp: 53.50, updatedAt: DateTime.now()),
    ]);
  }
}
