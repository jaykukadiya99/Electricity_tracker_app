import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../db/database_helper.dart';
import '../controllers/app_controller.dart';

class MeterInitialReadingsController extends GetxController {
  final int count;
  late final List<TextEditingController> readingsControllers;
  final isLoading = false.obs;

  MeterInitialReadingsController({required this.count});

  @override
  void onInit() {
    super.onInit();
    readingsControllers = List.generate(count, (_) => TextEditingController(text: '0.0'));
  }

  @override
  void onClose() {
    for (var controller in readingsControllers) {
      controller.dispose();
    }
    super.onClose();
  }

  Future<void> saveMeters() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      for (int i = 0; i < count; i++) {
        final readingText = readingsControllers[i].text;
        final reading = double.tryParse(readingText) ?? 0.0;
        await DatabaseHelper.instance.insertMeter({
          'meter_name': 'Meter ${i + 1}',
          'opening_reading': reading,
          'latest_reading': reading,
        });
      }

      final appCtrl = Get.find<AppController>();
      await appCtrl.checkSetupStatus();

      Get.offAllNamed('/main');
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Could not save meters: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
