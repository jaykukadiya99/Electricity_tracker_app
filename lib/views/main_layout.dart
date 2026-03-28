import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/meter_controller.dart';
import 'home_screen.dart';
import 'meters_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import '../controllers/reports_controller.dart';

class MainLayoutController extends GetxController {
  final currentIndex = 0.obs;
  
  void changeTab(int index) {
    currentIndex.value = index;
    if (index == 0 && Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().loadDashboardData();
    } else if (index == 1 && Get.isRegistered<MeterController>()) {
      Get.find<MeterController>().loadMeters();
    } else if (index == 2 && Get.isRegistered<ReportsController>()) {
      Get.find<ReportsController>().loadReports();
    }
  }
}

class MainLayout extends StatelessWidget {
  MainLayout({super.key});
  
  final MainLayoutController controller = Get.put(MainLayoutController());
  
  final List<Widget> pages = [
    HomeScreen(),
    MetersScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      body: IndexedStack(
        index: controller.currentIndex.value,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ]
        ),
        child: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).cardColor,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 10, letterSpacing: 0.5),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'HOME'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'METERS'),
            BottomNavigationBarItem(icon: Icon(Icons.description), label: 'REPORTS'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'SETTINGS'),
          ],
        ),
      ),
    ));
  }
}
