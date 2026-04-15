import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../controllers/settings_controller.dart';

class NewBillController extends GetxController {
  final meters = <Map<String, dynamic>>[].obs;
  final currentReadings = <String, double>{}.obs; // meterId -> currentReading
  final costPerUnit = 0.0.obs;
  final monthYearController = TextEditingController();
  final currentReadingController = TextEditingController();
  final costPerUnitController = TextEditingController();
  final isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    monthYearController.text = DateFormat('dd MMM yyyy').format(DateTime.now());
    // Pre-fill cost per unit from saved default
    final settingsCtrl = Get.find<SettingsController>();
    if (settingsCtrl.defaultUnitPrice.value > 0) {
      costPerUnit.value = settingsCtrl.defaultUnitPrice.value;
      costPerUnitController.text = settingsCtrl.defaultUnitPrice.value.toString();
    }
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

  void onMeterSelected(String meterId) {
    double val = currentReadings[meterId] ?? 0.0;
    double latest = meters.firstWhereOrNull((m) => m['id'] == meterId)?['latest_reading'] ?? 0.0;
    // Only prefill if the user has typed something different from latest reading
    currentReadingController.text = val > latest ? val.toString() : '';
  }

  void setCurrentReading(String meterId, String value) {
    if (value.isEmpty) return;
    currentReadings[meterId] = double.tryParse(value) ?? 0.0;
  }

  void setCostPerUnit(String value) {
    if (value.isEmpty) return;
    costPerUnit.value = double.tryParse(value) ?? 0.0;
  }

  Future<void> saveBill() async {
    if (isLoading.value) return;
    
    if (costPerUnit.value <= 0) {
      Get.snackbar('Error', 'Please enter a valid cost per unit', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red[100], colorText: Colors.red[900]);
      return;
    }

    if (monthYearController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a valid month/year', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red[100], colorText: Colors.red[900]);
      return;
    }

    // Validation
    bool hasAnyReading = false;
    for (var meter in meters) {
      String mId = meter['id'];
      if (!currentReadings.containsKey(mId)) continue;
      
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
      
      if (curReading > prevReading) {
        hasAnyReading = true;
      }
    }
    
    if (!hasAnyReading) {
      Get.snackbar('Error', 'Please enter a new reading greater than previous', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red[100], colorText: Colors.red[900]);
      return;
    }

    try {
      isLoading.value = true;
      String billId = await DatabaseHelper.instance.insertBillingHistory({
        'month_year': monthYearController.text.trim(),
        'total_cost_per_unit': costPerUnit.value,
        'date_added': DateTime.now().millisecondsSinceEpoch,
      });

      double totalAmount = 0.0;
      double totalConsumption = 0.0;

      for (var meter in meters) {
        String mId = meter['id'];
        if (!currentReadings.containsKey(mId)) continue;
        
        double prevReading = meter['latest_reading'];
        double curReading = currentReadings[mId] ?? 0.0;
        double consumption = curReading - prevReading;
        
        if (consumption <= 0) continue;
        
        double amount = consumption * costPerUnit.value;

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

        // Update latest reading in Meter
        await DatabaseHelper.instance.updateMeterLatestReading(mId, curReading);
      }
      
      await DatabaseHelper.instance.updateBillingHistoryTotals(billId, totalAmount, totalConsumption);
      
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
    } finally {
      isLoading.value = false;
    }
  }
}
