import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/models/service_marker.dart';

final serviceMarkersProvider = FutureProvider<List<ServiceMarker>>((ref) async {
  final dio = ref.read(dioProvider);
  
  try {
    // This endpoint is at /services/markers.json in home/urls.py
    // Note: The base URL in dio_client already includes /api/, 
    // but markers.json is NOT under /api/ in the current Django urls.py.
    // However, it's better to keep it consistent or update Django.
    // For now, we'll try to fetch it from the root.
    
    final baseUrl = dio.options.baseUrl.replaceAll('/api/', '');
    final response = await dio.get('$baseUrl/services/markers.json');
    
    final dynamic responseData = response.data;
    List<dynamic> markersJson = [];
    
    if (responseData is Map && responseData.containsKey('markers')) {
      markersJson = responseData['markers'];
    } else if (responseData is List) {
      markersJson = responseData;
    }
    
    return markersJson.map((json) => ServiceMarker.fromJson(json)).toList();
  } catch (e) {
    // If it fails, return empty list or rethrow
    return [];
  }
});
