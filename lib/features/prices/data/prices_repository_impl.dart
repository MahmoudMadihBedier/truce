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
                id: random.nextInt(10000),
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
        // Silently fail for mock APIs if needed
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
      // JUMIA DATA
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
        "Description": "Discover real Italian coffee in all its forms...",
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
        "Description": "Sokany Corded Lint Remover SK-877 is your go-to solution...",
        "Product Image URL": "https://eg.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/61/089915/1.jpg?4516",
        "Store": "Jumia"
      },
      {
        "Sr No": 7,
        "Product URL": "https://www.jumia.com.eg/oxi-oriental-breeze-powder-detergent-8-1-kilo-24675981.html",
        "Product ID": 24675981,
        "Product Name": "Oxi Oriental Breeze Powder Detergent - 8 + 1 Kilo",
        "Brand": "Oxi",
        "MRP (EGP)": 777,
        "Discount %": 31,
        "Price": 533,
        "Product Image URL": "https://eg.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/18/957642/1.jpg?7273",
        "Store": "Jumia"
      },
      // CARREFOUR DATA
      {
        "Sr No": 1,
        "Product URL": "https://www.carrefouregypt.com/mafegy/en/energy-drinks/redbull-energy-drink-250m-4/p/294682?offer=offer_carrefour_&sid=SLOTTED&sellerId=0000",
        "Product ID": 294682,
        "Product Name": "Red Bull Energy Drink - 250ml - 4 Packs",
        "Brand": "Red Bull",
        "MRP (EGP)": 219.95,
        "Discount %": 7,
        "Price": 204.99,
        "Description": "An energy drink enhanced with caffeine...",
        "Product Image URL": "https://cdn.mafrservices.com/pim-content/EGY/media/product/294682/1757842205/294682_main.jpg?im=Resize=58",
        "Store": "Carrefour"
      },
      {
        "Sr No": 2,
        "Product ID": 319132,
        "Product Name": "Koki Chicken Nuggets - 1.25 kg",
        "Brand": "Koki",
        "MRP (EGP)": 354.95,
        "Discount %": 24,
        "Price": 269.99,
        "Description": "Indulge in the delicious bite of the chicken...",
        "Product Image URL": "https://cdn.mafrservices.com/pim-content/EGY/media/product/319132/1760260070/319132_main.jpg?im=Resize=58",
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
        "Description": "This Gel is the first solution for your clothes...",
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
    return (null, [
      GoldPrice(carat: '24K', buy: 4200, sell: 4250, updatedAt: DateTime.now()),
      GoldPrice(carat: '21K', buy: 3675, sell: 3720, updatedAt: DateTime.now()),
      GoldPrice(carat: '18K', buy: 3150, sell: 3190, updatedAt: DateTime.now()),
    ]);
  }

  @override
  Future<ApiResult<List<CurrencyRate>>> getCurrencyRates() async {
    return (null, [
      CurrencyRate(code: 'USD', rateToEgp: 53.50, updatedAt: DateTime.now()),
    ]);
  }
}
