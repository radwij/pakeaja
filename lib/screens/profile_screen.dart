import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF0B57D0),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person, color: Color(0xFF0B57D0)),
                  title: const Text('User Profile'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/user-profile'),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.list_alt, color: Color(0xFF0B57D0)),
                  title: const Text('Manage User Listing'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/user-listing'),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.outbox, color: Color(0xFF0B57D0)),
                  title: const Text('Currently Rented Out'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/rented-out'),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(
                    Icons.shopping_bag,
                    color: Color(0xFF0B57D0),
                  ),
                  title: const Text('Currently Renting'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/currently-renting'),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    await Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    ).logout();
                    context.go('/login');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
