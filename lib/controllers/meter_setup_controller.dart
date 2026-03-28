import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MeterSetupController extends GetxController {
  final meterCountController = TextEditingController();
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
    Get.toNamed('/initial_readings', arguments: {'count': count});
  }
}
