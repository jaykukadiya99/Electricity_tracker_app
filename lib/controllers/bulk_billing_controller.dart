import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';

class BulkBillingController extends GetxController {
  final meters = <Map<String, dynamic>>[].obs;
  final readingsControllers = <String, TextEditingController>{};
  final monthYearController = TextEditingController();
  final costPerUnitController = TextEditingController();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    monthYearController.text = DateFormat('dd MMM yyyy').format(DateTime.now());
    loadMeters();
  }

  Future<void> loadMeters() async {
    final data = await DatabaseHelper.instance.getAllMeters();
    meters.value = data;
    for (var m in data) {
      readingsControllers[m['id']] = TextEditingController(text: '');
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      monthYearController.text = DateFormat('dd MMM yyyy').format(picked);
    }
  }

  Future<void> saveBulkBill() async {
    if (isLoading.value) return;
    
    final costPerUnit = double.tryParse(costPerUnitController.text) ?? 0.0;
    if (costPerUnit <= 0) {
      Get.snackbar(
        'Error', 'Please enter a valid cost per unit',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100], colorText: Colors.red[900]
      );
      return;
    }
    if (monthYearController.text.trim().isEmpty) {
      Get.snackbar(
        'Error', 'Please enter a valid month/year',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100], colorText: Colors.red[900]
      );
      return;
    }

    // Validation
    bool hasAnyReading = false;
    for (var meter in meters) {
      String mId = meter['id'];
      String text = readingsControllers[mId]?.text.trim() ?? '';
      if (text.isNotEmpty) {
        hasAnyReading = true;
        double curReading = double.tryParse(text) ?? 0.0;
        double prevReading = meter['latest_reading'] ?? 0.0;
        if (curReading < prevReading) {
          Get.snackbar(
            'Error', 'Logic error for ${meter['meter_name']}:\nCurrent ($curReading) < Previous ($prevReading)',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red[100], colorText: Colors.red[900],
            duration: const Duration(seconds: 4),
          );
          return;
        }
      }
    }

    if (!hasAnyReading) {
      Get.snackbar(
        'Error', 'Please enter at least one meter reading',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100], colorText: Colors.red[900]
      );
      return;
    }

    try {
      isLoading.value = true;
      String billId = await DatabaseHelper.instance.insertBillingHistory({
        'month_year': monthYearController.text.trim(),
        'total_cost_per_unit': costPerUnit,
        'date_added': DateTime.now().millisecondsSinceEpoch,
      });

      double totalAmount = 0.0;
      double totalConsumption = 0.0;

      for (var meter in meters) {
        String mId = meter['id'];
        String text = readingsControllers[mId]?.text.trim() ?? '';
        if (text.isNotEmpty) {
          double curReading = double.tryParse(text) ?? 0.0;
          double prevReading = meter['latest_reading'] ?? 0.0;
          double consumption = curReading - prevReading;
          double amount = consumption * costPerUnit;

          await DatabaseHelper.instance.insertBillingRecord({
            'bill_id': billId,
            'meter_id': mId,
            'previous_reading': prevReading,
            'current_reading': curReading,
            'consumption': consumption,
            'amount': amount,
            'created_at': DateTime.now().millisecondsSinceEpoch,
            'meter_name': meter['meter_name'],
            'month_year': monthYearController.text.trim(),
          });

          totalAmount += amount;
          totalConsumption += consumption;

          await DatabaseHelper.instance.updateMeterLatestReading(mId, curReading);
        }
      }
      
      await DatabaseHelper.instance.updateBillingHistoryTotals(billId, totalAmount, totalConsumption);
      
      final billMap = {
        'id': billId,
        'month_year': monthYearController.text.trim(),
        'total_cost_per_unit': costPerUnit,
        'date_added': DateTime.now().millisecondsSinceEpoch,
      };

      Get.offNamed('/bill_details', arguments: {'bill': billMap});
      Get.snackbar('Success', 'Bulk bill created successfully', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green[100], colorText: Colors.green[900]);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save bulk bill: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red[100], colorText: Colors.red[900]);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    for (var controller in readingsControllers.values) {
      controller.dispose();
    }
    super.onClose();
  }
}
