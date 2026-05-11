import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/dio_client.dart';
import '../models/product.dart';

final productListProvider = FutureProvider<List<Product>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('products/');
  
  final dynamic responseData = response.data;
  List<dynamic> data;
  
  if (responseData is Map) {
    data = responseData['results'] ?? responseData['data'] ?? [];
  } else if (responseData is List) {
    data = responseData;
  } else {
    data = [];
  }
  
  return data.map((json) => Product.fromJson(json)).toList();
});
