import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/marketplace_provider.dart';
import '../widgets/booking_bottom_sheet.dart';
import '../../../core/models/product.dart';
import '../../chat/screens/chat_detail_screen.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  final _bidController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  Future<void> _placeBid(String productId) async {
    final amount = double.tryParse(_bidController.text);
    if (amount == null) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(marketplaceServiceProvider).placeBid(productId, amount);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bid placed successfully!')),
        );
        _bidController.clear();
        ref.invalidate(productDetailProvider(productId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productDetailAsync = ref.watch(productDetailProvider(widget.productId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: productDetailAsync.when(
        data: (product) => _buildBody(context, product),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Scaffold(
          appBar: AppBar(),
          body: Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Product product) {
    final currencyFormat = NumberFormat.currency(symbol: 'NPR ', decimalDigits: 0);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 400,
          pinned: true,
          backgroundColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            background: CachedNetworkImage(
              imageUrl: product.image ?? '',
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[100],
                child: const Icon(Icons.image_outlined, size: 100, color: Colors.grey),
              ),
            ),
          ),
          leading: IconButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.arrow_back, color: Colors.black),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.favorite_border, color: Colors.black),
              ),
              onPressed: () {},
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getTypeColor(product.listingType).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.listingType.name.toUpperCase(),
                        style: TextStyle(
                          color: _getTypeColor(product.listingType),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.remove_red_eye_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    const Text('234 views', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  product.title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormat.format(product.price),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFBC252A),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  product.description,
                  style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                ),
                const SizedBox(height: 32),
                _buildSellerCard(product),
                const SizedBox(height: 32),
                if (product.listingType == ListingType.auction) _buildAuctionSection(product),
                const SizedBox(height: 32),
                // Map placeholder (assuming coordinates might be missing in model for now)
                const Text('Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(child: Text('Map View', style: TextStyle(color: Colors.grey))),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSellerCard(Product product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFFBC252A).withOpacity(0.1),
            child: Text(
              product.seller.username[0].toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFBC252A)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.seller.username,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Text('Verified Seller', style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(
                    conversationId: 'mock-id',
                    otherUsername: product.seller.username,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFFBC252A)),
          ),
        ],
      ),
    );
  }

  Widget _buildAuctionSection(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Auction Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Ends in:'),
            Text(
              product.auctionEnd != null ? DateFormat.yMMMd().add_jm().format(product.auctionEnd!) : 'No end date',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Highest Bid:'),
            Text(
              'NPR ${product.highestBid ?? product.price}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _bidController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter your bid',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _isSubmitting ? null : () => _placeBid(product.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBC252A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Bid'),
            ),
          ],
        ),
      ],
    );
  }

  Color _getTypeColor(ListingType type) {
    switch (type) {
      case ListingType.auction: return Colors.orange.shade700;
      case ListingType.rental: return Colors.green.shade700;
      case ListingType.service: return Colors.blue.shade700;
      case ListingType.sell: return const Color(0xFFBC252A);
    }
  }
}
