import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_controller.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key}) {
    _navigate();
  }

  void _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    final AppController appCtrl = Get.find<AppController>();
    if (appCtrl.isSetupComplete) {
      Get.offAllNamed('/main');
    } else {
      Get.offAllNamed('/setup');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.electric_bolt, size: 80, color: Theme.of(context).primaryColor),
            const SizedBox(height: 20),
            Text(
              'ElecTrack',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
