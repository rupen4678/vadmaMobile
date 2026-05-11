import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/marketplace_service.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/models/product.dart';

final marketplaceServiceProvider = Provider((ref) {
  final dio = ref.read(dioProvider);
  return MarketplaceService(dio);
});

final categoriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(marketplaceServiceProvider);
  final response = await service.getCategories();
  final List data = (response.data is Map) ? response.data['data'] : response.data;
  return data.cast<Map<String, dynamic>>();
});

final featuredProductsProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.watch(marketplaceServiceProvider);
  final response = await service.getFeaturedProducts();
  
  final dynamic responseData = response.data;
  List<dynamic> data;

  if (responseData is Map) {
    data = responseData['results'] ?? responseData['data'] ?? [];
  } else if (responseData is List) {
    data = responseData;
  } else {
    data = [];
  }
  
  return data.map((json) {
    // Some endpoints might wrap the product in a 'products' key
    final productJson = (json is Map && json.containsKey('products')) ? json['products'] : json;
    return Product.fromJson(productJson as Map<String, dynamic>);
  }).toList();
});

class ProductListNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final MarketplaceService _service;
  final String? _listingType;
  String? _searchQuery;
  String? _categoryId;
  int _page = 1;
  bool _hasMore = true;

  ProductListNotifier(this._service, this._listingType) : super(const AsyncValue.loading()) {
    loadProducts();
  }

  Future<void> loadProducts({bool refresh = false, String? search, String? categoryId}) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
      _searchQuery = search ?? _searchQuery;
      _categoryId = categoryId ?? _categoryId;
      state = const AsyncValue.loading();
    }

    if (!_hasMore && !refresh) return;

    try {
      final response = await _service.getProducts(
        listingType: _listingType,
        page: _page,
        search: _searchQuery,
        category: _categoryId,
      );

      final List data = (response.data is Map) ? (response.data['data'] ?? response.data['results'] ?? []) : response.data;
      final newProducts = data.map((json) => Product.fromJson(json)).toList();

      if (refresh) {
        state = AsyncValue.data(newProducts);
      } else {
        final currentProducts = state.value ?? [];
        state = AsyncValue.data([...currentProducts, ...newProducts]);
      }

      _hasMore = newProducts.length >= 20;
      _page++;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final productsProvider = StateNotifierProvider.family<ProductListNotifier, AsyncValue<List<Product>>, String?>((ref, listingType) {
  final service = ref.watch(marketplaceServiceProvider);
  return ProductListNotifier(service, listingType);
});

final productDetailProvider = FutureProvider.family<Product, String>((ref, productId) async {
  final service = ref.watch(marketplaceServiceProvider);
  final response = await service.getProductDetail(productId);
  final data = (response.data is Map && response.data.containsKey('data')) ? response.data['data'] : response.data;
  return Product.fromJson(data);
});
