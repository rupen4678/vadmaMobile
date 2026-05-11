import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final auctionSocketProvider = Provider.family<WebSocketChannel, String>((ref, auctionId) {
  return WebSocketChannel.connect(
    Uri.parse('ws://10.0.2.2:8000/ws/auctions/'),
  );
});
