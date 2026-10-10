import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import '../services/api.dart';
import '../services/auth_service.dart';

class ChatScreen extends StatefulWidget {
  final int conversationId;
  const ChatScreen({super.key, required this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List messages = [];
  final _controller = TextEditingController();
  bool loading = true;
  bool connected = false;
  WebSocketChannel? _channel;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _connectWebSocket();
  }

  Future<void> _loadHistory() async {
    try {
      final res = await Api.get('/chat/conversations/${widget.conversationId}/messages/');
      if (res.statusCode == 200) {
        if (mounted) setState(() => messages = jsonDecode(res.body));
      }
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  void _connectWebSocket() {
    final apiUri = Uri.parse(Api.baseUrl);
    final uri = apiUri.replace(
      scheme: apiUri.scheme == 'https' ? 'wss' : 'ws',
      path: '/ws/chat/${widget.conversationId}/',
      query: null,
      fragment: null,
    );
    _channel = WebSocketChannel.connect(uri);

    _channel!.stream.listen(
      (message) {
        try {
          final data = jsonDecode(message);
          if (!mounted) return;
          setState(() {
            // Avoid duplicates
            if (!messages.any((m) => m['id'] == data['id'])) {
              messages.add(data);
            }
          });
        } catch (_) {}
      },
      onDone: () { if (mounted) setState(() => connected = false); },
      onError: (_) { if (mounted) setState(() => connected = false); },
    );

    if (mounted) setState(() => connected = true);
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || _channel == null) return;
    _channel!.sink.add(jsonEncode({'message': text}));
    _controller.clear();
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myId = context.watch<AuthService>().user?['id'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                connected ? '● Live' : '○ Offline',
                style: TextStyle(
                  fontSize: 12,
                  color: connected ? Colors.green : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                    ? const Center(child: Text('No messages yet. Say hello!'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: messages.length,
                        itemBuilder: (context, i) {
                          final m = messages[i];
                          final isMe = m['sender']?['id'] == myId;
                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isMe ? const Color(0xFF17151C) : const Color(0xFFF7F5FA),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                m['content'] ?? '',
                                style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: connected,
                      decoration: InputDecoration(
                        hintText: connected ? 'Write a message...' : 'Connecting...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: connected ? _send : null,
                    icon: Icon(Icons.send, color: connected ? const Color(0xFF0095F6) : Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
