import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../db/database_helper.dart';

class BillDetailsController extends GetxController {
  final String billId;
  final isLoading = true.obs;
  final records = <Map<String, dynamic>>[].obs;
  final meters = <String, String>{}.obs;

  final ScreenshotController screenshotController = ScreenshotController();

  BillDetailsController({required this.billId});

  @override
  void onInit() {
    super.onInit();
    loadDetails();
  }

  Future<void> loadDetails() async {
    isLoading.value = true;
    final allMeters = await DatabaseHelper.instance.getAllMeters();
    for (var m in allMeters) {
      meters[m['id']] = m['meter_name'];
    }

    final data = await DatabaseHelper.instance.getBillingRecords(billId);
    records.value = data;
    isLoading.value = false;
  }

  Future<void> shareBillAsImage(BuildContext context, Widget shareWidget) async {
    try {
      // Capture the widget directly to memory instead of rendering it on screen
      final bytes = await screenshotController.captureFromWidget(
        shareWidget,
        context: context,
        delay: const Duration(milliseconds: 100),
      );

      // Save to temp directory
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/invoice_$billId.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(bytes);

      // Share it
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: 'Monthly Utility Invoice Breakdown',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate image: $e', 
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.red[100], 
          colorText: Colors.red[900]);
    }
  }
}
