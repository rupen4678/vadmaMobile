import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../models/message.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String otherUser;

  const ChatRoomScreen({super.key, required this.conversationId, required this.otherUser});

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final TextEditingController _controller = TextEditingController();
  late WebSocketChannel _channel;
  final List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    // Connect to specific chat group
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://10.0.2.2:8000/ws/chat/${widget.conversationId}/'),
    );
    _listenToMessages();
  }

  void _listenToMessages() {
    _channel.stream.listen((data) {
      final decoded = json.decode(data);
      setState(() {
        _messages.add(Message.fromJson(decoded));
      });
    });
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      _channel.sink.add(json.encode({
        'action': 'message',
        'text': _controller.text,
      }));
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with ${widget.otherUser}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (ctx, i) => ListTile(
                title: Text(_messages[i].text),
                subtitle: Text(_messages[i].sender),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Type a message...'))),
                IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
