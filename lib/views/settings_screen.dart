import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/settings_controller.dart';
import '../db/database_helper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final AuthController authController = Get.find<AuthController>();
    final SettingsController settingsController = Get.find<SettingsController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(40),
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              authController.getCurrentUser()?.email ?? 'Unknown User',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Currently Logged In'),
          ),
          const Divider(),
          Obx(
            () => SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Toggle between light and dark themes'),
              value: themeController.isDarkMode,
              onChanged: (val) => themeController.toggleTheme(),
              secondary: Icon(
                themeController.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
            ),
          ),
          const Divider(),
          Obx(() => ListTile(
            leading: const Icon(Icons.electrical_services),
            title: const Text(
              'Default Unit Price',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              settingsController.defaultUnitPrice.value > 0
                  ? 'Rs. ${settingsController.defaultUnitPrice.value}/kWh  (tap to change)'
                  : 'Not set — tap to configure',
            ),
            trailing: const Icon(Icons.edit_outlined, size: 18),
            onTap: () => settingsController.showEditPriceDialog(context),
          )),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Reset All Data',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Wipe all history and tenants'),
            onTap: () => _confirmReset(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.indigo),
            title: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Sign out of your account'),
            onTap: () => authController.logout(),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Everything?'),
        content: const Text(
          'This will permanently delete all your tenants and billing history. This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await DatabaseHelper.instance.clearAllData();
              Get.offAllNamed('/setup');
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
