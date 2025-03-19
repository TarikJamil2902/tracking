import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.school,
                    size: 40,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'School Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context: context,
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  route: '/',
                  isSelected: currentRoute == '/',
                ),
                const Divider(height: 1),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.people,
                  title: 'Students',
                  route: '/students',
                  isSelected: currentRoute == '/students',
                ),
                const Divider(height: 1),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.map,
                  title: 'Track Bus',
                  route: '/map',
                  isSelected: currentRoute == '/map',
                ),
                const Divider(height: 1),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.assessment,
                  title: 'Reports',
                  route: '/reports',
                  isSelected: currentRoute == '/reports',
                ),
                const Divider(height: 1),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.notifications,
                  title: 'Notifications',
                  route: '/notifications',
                  isSelected: currentRoute == '/notifications',
                  showBadge: true, // You can control this with a provider later
                ),
                const Divider(height: 1),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.person,
                  title: 'Profile',
                  route: '/profile',
                  isSelected: currentRoute == '/profile',
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.settings,
                  title: 'Settings',
                  route: '/settings',
                  isSelected: currentRoute == '/settings',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue,
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Admin',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Principal',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
    required bool isSelected,
    bool showBadge = false,
  }) {
    final theme = Theme.of(context);
    
    return Material(
      color: isSelected ? theme.primaryColor.withOpacity(0.1) : null,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? theme.primaryColor : null,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? theme.primaryColor : null,
            fontWeight: isSelected ? FontWeight.w600 : null,
          ),
        ),
        trailing: showBadge
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '3',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              )
            : null,
        onTap: () {
          if (route != ModalRoute.of(context)?.settings.name) {
            Navigator.pop(context); // Close drawer
            Navigator.pushReplacementNamed(context, route);
          }
        },
      ),
    );
  }
}
