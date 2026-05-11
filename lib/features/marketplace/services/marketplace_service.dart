import 'package:dio/dio.dart';

class MarketplaceService {
  final Dio _dio;

  MarketplaceService(this._dio);

  Future<Response> getProducts({
    String? listingType,
    String? category,
    String? search,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
    };
    if (listingType != null) queryParams['listing_type'] = listingType;
    if (category != null) queryParams['category'] = category;
    if (search != null) queryParams['search'] = search;

    return await _dio.get('/products/', queryParameters: queryParams);
  }

  Future<Response> getCategories() async {
    return await _dio.get('/categories/');
  }

  Future<Response> getFeaturedProducts() async {
    return await _dio.get('/products/featured/');
  }

  Future<Response> getProductDetail(String productId) async {
    return await _dio.get('/products/$productId/');
  }

  Future<Response> placeBid(String productId, double amount) async {
    return await _dio.post('/auctions/$productId/bid/', data: {'amount': amount});
  }

  Future<Response> createBooking(String productId, Map<String, dynamic> data) async {
    return await _dio.post('/rental-bookings/', data: {
      'listing': productId,
      ...data,
    });
  }
}
