import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../db/database_helper.dart';
import '../services/pdf_service.dart';

class MeterHistoryController extends GetxController {
  final String meterId;
  final isLoading = true.obs;

  final meterData = <String, dynamic>{}.obs;
  final historyRecords = <Map<String, dynamic>>[].obs;

  final totalConsumption = 0.0.obs;
  final totalCost = 0.0.obs;

  MeterHistoryController({required this.meterId});

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> loadHistory() async {
    isLoading.value = true;

    final meter = await DatabaseHelper.instance.getMeter(meterId);
    if (meter != null) {
      meterData.value = meter;
    }

    final records = await DatabaseHelper.instance.getMeterHistory(meterId);
    // Filter only records that have >0 consumption so we only show billed cycles
    final activeRecords = records
        .where((r) => (r['consumption'] ?? 0.0) > 0)
        .toList();
    historyRecords.value = activeRecords;

    double tCons = 0;
    double tCost = 0;
    for (var r in activeRecords) {
      tCons += r['consumption'] ?? 0.0;
      tCost += r['amount'] ?? 0.0;
    }

    totalConsumption.value = tCons;
    totalCost.value = tCost;

    isLoading.value = false;
  }

  Future<void> deleteRecord(Map<String, dynamic> record) async {
    Get.defaultDialog(
      contentPadding: EdgeInsets.all(8),
      title: 'Delete Reading',
      middleText:
          'Are you sure you want to delete this reading? This will update the meter and parent bill totals.',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFFDC2626), // Red color
      cancelTextColor: const Color(0xFFDC2626),
      onConfirm: () async {
        Get.back(); // close dialog
        isLoading.value = true;
        try {
          String recordId = record['id'] ?? record['record_id'];
          String billId = record['bill_id'];
          double amount = (record['amount'] as num?)?.toDouble() ?? 0.0;
          double consumption =
              (record['consumption'] as num?)?.toDouble() ?? 0.0;

          await DatabaseHelper.instance.deleteBillingRecord(
            recordId,
            meterId,
            billId,
            amount,
            consumption,
          );

          Get.snackbar(
            'Success',
            'Reading deleted successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFDCFCE7),
            colorText: const Color(0xFF14532D),
          );

          // Reload history
          await loadHistory();
        } catch (e) {
          isLoading.value = false;
          Get.snackbar(
            'Error',
            'Failed to delete reading: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFFEE2E2),
            colorText: const Color(0xFF7F1D1D),
          );
        }
      },
    );
  }

  Future<void> exportToPdf() async {
    if (historyRecords.isEmpty) {
      Get.snackbar('Export Failed', 'No history records to export.');
      return;
    }

    final headers = ['Month/Year', 'Prev', 'Current', 'Usage', 'Amount'];
    final data = historyRecords
        .map(
          (r) => [
            r['month_year']?.toString() ?? '',
            r['previous_reading']?.toString() ?? '0.0',
            r['current_reading']?.toString() ?? '0.0',
            '${r['consumption']} kWh',
            'Rs. ${(r['amount'] ?? 0.0).toStringAsFixed(2)}',
          ],
        )
        .toList();

    await PdfService.generateAndShareReport(
      title: '${meterData['meter_name'] ?? 'Meter'}_History',
      headers: headers,
      data: data,
    );
  }
}
