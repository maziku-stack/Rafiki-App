import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List conversations = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await Api.get('/chat/conversations/');
      if (res.statusCode == 200) {
        if (mounted) setState(() => conversations = jsonDecode(res.body));
      }
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : conversations.isEmpty
              ? const Center(
                  child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.forum_outlined,
                            size: 42, color: Color(0xFF8C7BFF)),
                        SizedBox(height: 12),
                        Text('Your conversations start here',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF17151C))),
                        SizedBox(height: 8),
                        Text(
                            'Visit Connect to meet someone who is open to talking.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFF7C7885), height: 1.5))
                      ])))
              : ListView.builder(
                  itemCount: conversations.length,
                  itemBuilder: (context, i) {
                    final c = conversations[i];
                    final other = c['other_user'] ?? {};
                    final last = c['last_message'];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFEDE9FF),
                        child: Text(
                            (other['first_name'] ?? other['username'] ?? '?')[0]
                                .toUpperCase(),
                            style: const TextStyle(color: Color(0xFF5B49C8))),
                      ),
                      title: Text(
                          other['first_name'] ?? other['username'] ?? 'User'),
                      subtitle: Text(last != null
                          ? (last['content'] ?? '')
                          : 'Start chatting...'),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(conversationId: c['id']),
                          )),
                    );
                  },
                ),
    );
  }
}
