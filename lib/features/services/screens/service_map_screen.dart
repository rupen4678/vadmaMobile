import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/service_provider.dart';
import '../../marketplace/screens/product_detail_screen.dart';

class ServiceMapScreen extends ConsumerStatefulWidget {
  const ServiceMapScreen({super.key});

  @override
  ConsumerState<ServiceMapScreen> createState() => _ServiceMapScreenState();
}

class _ServiceMapScreenState extends ConsumerState<ServiceMapScreen> {
  bool _isMapView = false;

  @override
  Widget build(BuildContext context) {
    final markersAsync = ref.watch(serviceMarkersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Nearby Services', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(_isMapView ? Icons.list : Icons.map_outlined),
            onPressed: () => setState(() => _isMapView = !_isMapView),
          ),
        ],
      ),
      body: markersAsync.when(
        data: (markers) {
          if (markers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.build_circle_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No services found nearby.', style: GoogleFonts.poppins(color: Colors.grey[600])),
                ],
              ),
            );
          }

          if (_isMapView) {
            return const Center(
              child: Text("Google Maps Integration Ready\n(Requires API Key configuration)"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: markers.length,
            itemBuilder: (context, index) {
              final service = markers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFBC252A).withOpacity(0.1),
                    child: const Icon(Icons.build, color: Color(0xFFBC252A)),
                  ),
                  title: Text(service.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('NPR ${service.price}', style: const TextStyle(color: Color(0xFFBC252A), fontWeight: FontWeight.bold)),
                      if (service.avgRating != null)
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(service.avgRating!.toStringAsFixed(1), style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(productId: service.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('Error: $err', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
          ),
        ),
      ),
    );
  }
}
