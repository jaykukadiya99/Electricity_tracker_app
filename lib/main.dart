import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/theme_controller.dart';
import 'controllers/app_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/auth_middleware.dart';
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
import 'views/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Get.put(ThemeController());
  Get.put(AppController());
  Get.put(AuthController());

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
          GetPage(name: '/login', page: () => LoginScreen()),
          GetPage(
            name: '/setup',
            page: () => MeterSetupScreen(),
            middlewares: [AuthMiddleware()],
          ),
          GetPage(
            name: '/initial_readings',
            page: () => const MeterInitialReadingsScreen(),
            middlewares: [AuthMiddleware()],
          ),
          GetPage(
            name: '/meter_history',
            page: () => const MeterHistoryScreen(),
            middlewares: [AuthMiddleware()],
          ),
          GetPage(
            name: '/main',
            page: () => MainLayout(),
            middlewares: [AuthMiddleware()],
          ),
          GetPage(
            name: '/bulk_bill',
            page: () => BulkBillingScreen(),
            middlewares: [AuthMiddleware()],
          ),
          GetPage(
            name: '/new_bill',
            page: () => NewBillScreen(),
            middlewares: [AuthMiddleware()],
          ),
          GetPage(
            name: '/bill_details',
            page: () => BillDetailsScreen(),
            middlewares: [AuthMiddleware()],
          ),
          GetPage(
            name: '/settings',
            page: () => SettingsScreen(),
            middlewares: [AuthMiddleware()],
          ),
        ],
      ),
    );
  }
}
