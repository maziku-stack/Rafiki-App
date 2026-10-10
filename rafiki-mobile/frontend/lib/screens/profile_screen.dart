import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _name;
  late TextEditingController _bio;
  late String _intention;
  late bool _isOpen;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthService>().user;
    _name = TextEditingController(text: user?['first_name'] ?? '');
    _bio = TextEditingController(text: user?['bio'] ?? '');
    _intention = user?['intention'] ?? 'lonely';
    _isOpen = user?['is_open_to_chat'] ?? true;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await context.read<AuthService>().updateProfile({
      'first_name': _name.text,
      'bio': _bio.text,
      'intention': _intention,
      'is_open_to_chat': _isOpen,
    });
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profile updated')));
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().user;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 45,
              backgroundColor: const Color(0xFFEDE9FF),
              child: Text(
                (user?['first_name'] ?? user?['username'] ?? '?')[0]
                    .toUpperCase(),
                style: const TextStyle(fontSize: 36, color: Color(0xFF5B49C8)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
              child: Text('@${user?['username'] ?? ''}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600))),
          const SizedBox(height: 24),
          TextField(
              controller: _name,
              decoration: const InputDecoration(
                  labelText: 'Display name', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(
              controller: _bio,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'Bio', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _intention,
            decoration: const InputDecoration(
                labelText: 'Intention', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'lonely', child: Text('Feeling lonely')),
              DropdownMenuItem(
                  value: 'deep_talk', child: Text('Want deep talk')),
              DropdownMenuItem(
                  value: 'share_ideas', child: Text('Share ideas')),
              DropdownMenuItem(
                  value: 'casual_chat', child: Text('Casual chat')),
              DropdownMenuItem(
                  value: 'need_support', child: Text('Need support')),
            ],
            onChanged: (v) => setState(() => _intention = v!),
          ),
          SwitchListTile(
            title: const Text("I'm open to chat"),
            value: _isOpen,
            onChanged: (v) => setState(() => _isOpen = v),
            activeThumbColor: const Color(0xFF0095F6),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0095F6),
                  foregroundColor: Colors.white),
              child: _saving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}
