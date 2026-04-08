import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/theme_controller.dart';
import 'controllers/app_controller.dart';
import 'theme/app_theme.dart';
import 'views/splash_screen.dart';
import 'views/meter_setup_screen.dart';
import 'views/meter_initial_readings_screen.dart';
import 'views/bulk_billing_screen.dart';
import 'views/meter_history_screen.dart';
import 'views/main_layout.dart';
import 'views/new_bill_screen.dart';
import 'views/bill_details_screen.dart';
import 'views/settings_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ThemeController());
  Get.put(AppController());

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        builder: (context, child) {
          return SafeArea(
            top: false, // AppBar handles top SafeArea already
            child: child ?? const SizedBox.shrink(),
          );
        },
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => SplashScreen()),
          GetPage(name: '/setup', page: () => MeterSetupScreen()),
          GetPage(
            name: '/initial_readings',
            page: () => const MeterInitialReadingsScreen(),
          ),
          GetPage(
            name: '/meter_history',
            page: () => const MeterHistoryScreen(),
          ),
          GetPage(name: '/main', page: () => MainLayout()),
          GetPage(name: '/bulk_bill', page: () => BulkBillingScreen()),
          GetPage(name: '/new_bill', page: () => NewBillScreen()),
          GetPage(name: '/bill_details', page: () => BillDetailsScreen()),
          GetPage(name: '/settings', page: () => SettingsScreen()),
        ],
      ),
    );
  }
}
