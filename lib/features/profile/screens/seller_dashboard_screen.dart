import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../marketplace/providers/marketplace_provider.dart';
import '../../marketplace/widgets/product_card.dart';
import '../../marketplace/screens/product_detail_screen.dart';
import '../../../core/models/product.dart';

class SellerDashboardScreen extends ConsumerWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real app, we would have a specific provider for user's own products
    final productsAsync = ref.watch(productsProvider(null));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _buildStats(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'My Listings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: productsAsync.when(
              data: (products) => ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: products.length > 3 ? 3 : products.length, // Mocking own products
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.image ?? '', 
                          width: 50, 
                          height: 50, 
                          fit: BoxFit.cover, 
                          errorBuilder: (_,__,___) => const Icon(Icons.image)
                        ),
                      ),
                      title: Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('NPR ${product.price}', style: const TextStyle(color: Color(0xFFBC252A))),
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(productId: product.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Active', '12'),
          _buildStatItem('Sold', '45'),
          _buildStatItem('Rating', '4.8'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFBC252A))),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
