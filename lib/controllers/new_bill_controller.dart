import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';

class NewBillController extends GetxController {
  final meters = <Map<String, dynamic>>[].obs;
  final currentReadings = <int, double>{}.obs; // meterId -> currentReading
  final costPerUnit = 0.0.obs;
  final monthYearController = TextEditingController();
  final currentReadingController = TextEditingController();
  
  @override
  void onInit() {
    super.onInit();
    monthYearController.text = DateFormat('dd MMM yyyy').format(DateTime.now());
    loadMeters();
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

  Future<void> loadMeters() async {
    final data = await DatabaseHelper.instance.getAllMeters();
    meters.value = data;
    for (var m in data) {
      currentReadings[m['id']] = (m['latest_reading'] as num?)?.toDouble() ?? 0.0;
    }
  }

  void onMeterSelected(int meterId) {
    double val = currentReadings[meterId] ?? 0.0;
    double latest = meters.firstWhereOrNull((m) => m['id'] == meterId)?['latest_reading'] ?? 0.0;
    // Only prefill if the user has typed something different from latest reading
    currentReadingController.text = val > latest ? val.toString() : '';
  }

  void setCurrentReading(int meterId, String value) {
    if (value.isEmpty) return;
    currentReadings[meterId] = double.tryParse(value) ?? 0.0;
  }

  void setCostPerUnit(String value) {
    if (value.isEmpty) return;
    costPerUnit.value = double.tryParse(value) ?? 0.0;
  }

  Future<void> saveBill() async {
    if (costPerUnit.value <= 0) {
      Get.snackbar('Error', 'Please enter a valid cost per unit', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red[100], colorText: Colors.red[900]);
      return;
    }

    if (monthYearController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a valid month/year', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red[100], colorText: Colors.red[900]);
      return;
    }

    // Validation
    for (var meter in meters) {
      int mId = meter['id'];
      double prevReading = meter['latest_reading'];
      double curReading = currentReadings[mId] ?? 0.0;
      if (curReading < prevReading) {
        Get.snackbar(
          'Error', 
          'Logic error for ${meter['meter_name']}.\nCurrent ($curReading) cannot be less than previous ($prevReading)', 
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          duration: const Duration(seconds: 4),
        );
        return;
      }
    }

    try {
      int billId = await DatabaseHelper.instance.insertBillingHistory({
        'month_year': monthYearController.text.trim(),
        'total_cost_per_unit': costPerUnit.value,
        'date_added': DateTime.now().millisecondsSinceEpoch,
      });

      for (var meter in meters) {
        int mId = meter['id'];
        double prevReading = meter['latest_reading'];
        double curReading = currentReadings[mId] ?? 0.0;
        double consumption = curReading - prevReading;
        double amount = consumption * costPerUnit.value;

        await DatabaseHelper.instance.insertBillingRecord({
          'bill_id': billId,
          'meter_id': mId,
          'previous_reading': prevReading,
          'current_reading': curReading,
          'consumption': consumption,
          'amount': amount,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        });

        // Update latest reading in Meter
        await DatabaseHelper.instance.updateMeterLatestReading(mId, curReading);
      }
      
      final billMap = {
        'id': billId,
        'month_year': monthYearController.text.trim(),
        'total_cost_per_unit': costPerUnit.value,
        'date_added': DateTime.now().millisecondsSinceEpoch,
      };

      Get.offNamed('/bill_details', arguments: {'bill': billMap});
      Get.snackbar('Success', 'Bill created successfully', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green[100], colorText: Colors.green[900]);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save bill: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red[100], colorText: Colors.red[900]);
    }
  }
}
