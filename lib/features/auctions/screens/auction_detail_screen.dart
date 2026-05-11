import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../providers/auction_socket_provider.dart';

class AuctionDetailScreen extends ConsumerStatefulWidget {
  final String auctionId;
  final String title;
  final double currentPrice;

  const AuctionDetailScreen({
    super.key,
    required this.auctionId,
    required this.title,
    required this.currentPrice,
  });

  @override
  ConsumerState<AuctionDetailScreen> createState() => _AuctionDetailScreenState();
}

class _AuctionDetailScreenState extends ConsumerState<AuctionDetailScreen> {
  late WebSocketChannel channel;
  double? livePrice;
  final TextEditingController _bidController = TextEditingController();

  @override
  void initState() {
    super.initState();
    livePrice = widget.currentPrice;
    channel = ref.read(auctionSocketProvider(widget.auctionId));
    _listenToBids();
  }

  void _listenToBids() {
    channel.stream.listen((message) {
      // In a real app, parse the JSON to get the new bid amount
      // final data = json.decode(message);
      // setState(() => livePrice = data['new_bid']);
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    _bidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Current Price', style: Theme.of(context).textTheme.titleMedium),
            Text('NPR ${livePrice!.toStringAsFixed(2)}', 
                 style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 20),
            TextField(
              controller: _bidController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Enter your bid', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // channel.sink.add(json.encode({'action': 'bid', 'amount': _bidController.text}));
              },
              child: const Text('Place Bid'),
            ),
          ],
        ),
      ),
    );
  }
}
