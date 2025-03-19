import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Settings'),
      ),
      drawer: const AppDrawer(),
      body: ListView(
        children: [
          _buildSection(
            'Account Settings',
            [
              _buildSettingTile(
                'Profile Information',
                'Update your personal details',
                Icons.person,
                onTap: () {},
              ),
              _buildSettingTile(
                'Change Password',
                'Update your password',
                Icons.lock,
                onTap: () {},
              ),
            ],
          ),
          _buildSection(
            'Notification Settings',
            [
              _buildSettingTile(
                'Push Notifications',
                'Manage app notifications',
                Icons.notifications,
                onTap: () {},
              ),
              _buildSettingTile(
                'Email Notifications',
                'Manage email alerts',
                Icons.email,
                onTap: () {},
              ),
            ],
          ),
          _buildSection(
            'App Settings',
            [
              _buildSettingTile(
                'Language',
                'Change app language',
                Icons.language,
                onTap: () {},
              ),
              _buildSettingTile(
                'Theme',
                'Change app appearance',
                Icons.palette,
                onTap: () {},
              ),
              _buildSettingTile(
                'Data Usage',
                'Manage data and storage',
                Icons.data_usage,
                onTap: () {},
              ),
            ],
          ),
          _buildSection(
            'System',
            [
              _buildSettingTile(
                'About',
                'App information and version',
                Icons.info,
                onTap: () {},
              ),
              _buildSettingTile(
                'Help & Support',
                'Get assistance',
                Icons.help,
                onTap: () {},
              ),
              _buildSettingTile(
                'Privacy Policy',
                'Read our privacy policy',
                Icons.privacy_tip,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
