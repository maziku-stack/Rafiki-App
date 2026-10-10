import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api.dart';
import 'dart:convert';
import 'connect_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _pages = const [
    _AvailableUsersTab(),
    ConnectScreen(),
    MessagesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF8C7BFF),
        unselectedItemColor: const Color(0xFF7C7885),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Connect'),
          BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class _AvailableUsersTab extends StatefulWidget {
  const _AvailableUsersTab();

  @override
  State<_AvailableUsersTab> createState() => _AvailableUsersTabState();
}

class _AvailableUsersTabState extends State<_AvailableUsersTab> {
  List users = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await Api.get('/auth/available/');
      if (res.statusCode == 200) {
        if (mounted) setState(() => users = jsonDecode(res.body));
      }
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  Future<void> _startChat(int userId) async {
    final res = await Api.post('/chat/conversations/create/', {'user_id': userId});
    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => ChatScreen(conversationId: data['id']),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().user;
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Discover', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF17151C))),
            Text('📍 Dar es Salaam, Tanzania', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF7C7885))),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthService>().logout();
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.people_alt_outlined, size: 42, color: Color(0xFF8C7BFF)),
                        const SizedBox(height: 14),
                        const Text('Your next good conversation is out there', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF17151C))),
                        const SizedBox(height: 8),
                        const Text('There’s no one new to show right now. Check back soon or explore people by how they feel.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF7C7885), height: 1.5)),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _load,
                          child: const Text('Refresh people'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length + 1,
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Hello, ${user?['first_name'] ?? user?['username'] ?? ''} 👋\nPeople open to talk',
                          style: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF7C7885)),
                        ),
                      );
                    }
                    final u = users[i - 1];
                    final firstName = (u['first_name'] ?? '').toString().trim();
                    final username = (u['username'] ?? '').toString().trim();
                    final displayName = firstName.isNotEmpty
                        ? firstName
                        : username.isNotEmpty
                            ? username
                            : 'Someone';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFEEEBF2))),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFEDE9FF),
                          child: Text(
                            displayName[0].toUpperCase(),
                            style: const TextStyle(color: Color(0xFF5B49C8), fontWeight: FontWeight.w700),
                          ),
                        ),
                        title: Text(displayName),
                        subtitle: Text(
                          (u['intention'] ?? '').toString().replaceAll('_', ' '),
                          style: const TextStyle(color: Color(0xFF7C7885)),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _startChat(u['id']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF17151C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: const Text('Chat'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
