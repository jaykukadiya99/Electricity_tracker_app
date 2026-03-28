import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/theme_controller.dart';
import 'controllers/app_controller.dart';
import 'theme/app_theme.dart';
import 'views/splash_screen.dart';
import 'views/main_layout.dart';
import 'views/new_bill_screen.dart';
import 'views/bill_details_screen.dart';
import 'views/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ThemeController());
  Get.put(AppController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return Obx(
      () => GetMaterialApp(
        title: 'ElecTrack',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        themeMode: themeController.isDarkMode
            ? ThemeMode.dark
            : ThemeMode.light,
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => SplashScreen()),
          GetPage(name: '/main', page: () => MainLayout()),
          GetPage(name: '/new_bill', page: () => NewBillScreen()),
          GetPage(name: '/bill_details', page: () => BillDetailsScreen()),
          GetPage(name: '/settings', page: () => SettingsScreen()),
        ],
      ),
    );
  }
}
