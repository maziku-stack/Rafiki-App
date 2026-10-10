import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../services/auth_service.dart';
import '../services/api.dart';
import 'chat_screen.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  String _intention = 'lonely';
  List users = [];
  bool searched = false;
  bool loading = false;

  final intentions = {
    'lonely': ('Feeling lonely', ''),
    'deep_talk': ('Want deep talk', ''),
    'share_ideas': ('Share ideas', ''),
    'casual_chat': ('Casual chat', ''),
    'need_support': ('Need support', ' '),
  };

  Future<void> _find() async {
    setState(() {
      loading = true;
      searched = true;
      users = [];
    });
    try {
      await context
          .read<AuthService>()
          .updateProfile({'intention': _intention});
      final res = await Api.get('/auth/available/?intention=$_intention');
      if (res.statusCode == 200) {
        if (mounted) setState(() => users = jsonDecode(res.body));
      }
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  Future<void> _startChat(int userId) async {
    final res =
        await Api.post('/chat/conversations/create/', {'user_id': userId});
    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      if (mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(conversationId: data['id']),
            ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Connect',
              style: TextStyle(fontWeight: FontWeight.w800))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
                alignment: Alignment.centerLeft,
                child: Text('Find your kind of conversation',
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF17151C)))),
            const SizedBox(height: 8),
            const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    'Choose what feels right today. Meet someone who is open to the same kind of conversation.',
                    style: TextStyle(color: Color(0xFF7C7885), height: 1.5))),
            const SizedBox(height: 12),
            const Align(
                alignment: Alignment.centerLeft,
                child: Text('📍 Dar es Salaam, Tanzania',
                    style: TextStyle(color: Color(0xFF7C7885), fontSize: 13))),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: intentions.entries.map((e) {
                final selected = _intention == e.key;
                return ChoiceChip(
                  label: Text('${e.value.$2} ${e.value.$1}'),
                  selected: selected,
                  onSelected: (_) => setState(() => _intention = e.key),
                  selectedColor: const Color(0xFFEDE9FF),
                  labelStyle: TextStyle(
                      color: selected
                          ? const Color(0xFF5B49C8)
                          : const Color(0xFF17151C)),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: loading ? null : _find,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF17151C),
                    foregroundColor: Colors.white),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Find People'),
              ),
            ),
            const SizedBox(height: 24),
            if (searched)
              users.isEmpty
                  ? const Column(
                      children: [
                        Text('No one is looking for this just now',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF17151C))),
                        SizedBox(height: 12),
                        Text(
                            'Try another conversation style or check back later.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF7C7885))),
                      ],
                    )
                  : Column(
                      children: users.map((u) {
                        final firstName =
                            (u['first_name'] ?? '').toString().trim();
                        final username =
                            (u['username'] ?? '').toString().trim();
                        final displayName = firstName.isNotEmpty
                            ? firstName
                            : username.isNotEmpty
                                ? username
                                : 'Someone';
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFEDE9FF),
                              child: Text(displayName[0].toUpperCase(),
                                  style: const TextStyle(
                                      color: Color(0xFF5B49C8))),
                            ),
                            title: Text(displayName),
                            trailing: ElevatedButton(
                              onPressed: () => _startChat(u['id']),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF17151C),
                                  foregroundColor: Colors.white),
                              child: const Text('Chat'),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
          ],
        ),
      ),
    );
  }
}
