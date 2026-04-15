import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class MeterSetupController extends GetxController {
  final meterCountController = TextEditingController();
  final defaultUnitPriceController = TextEditingController();
  final isLoading = false.obs;

  void proceedToReadings() {
    final count = int.tryParse(meterCountController.text) ?? 0;
    if (count <= 0) {
      Get.snackbar(
        'Invalid Input',
        'Please enter a valid number of meters.',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Save default unit price if provided
    final priceText = defaultUnitPriceController.text.trim();
    final price = double.tryParse(priceText) ?? 0.0;
    if (price > 0) {
      Get.find<SettingsController>().saveDefaultUnitPrice(price);
    }

    Get.toNamed('/initial_readings', arguments: {'count': count});
  }
}
