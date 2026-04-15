import 'package:get/get.dart';
import '../db/database_helper.dart';

class MeterController extends GetxController {
  final meters = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadMeters();
  }

  Future<void> loadMeters() async {
    isLoading.value = true;
    final data = await DatabaseHelper.instance.getAllMeters();
    meters.value = data;
    isLoading.value = false;
  }

  Future<void> addMeter(String name, double openingReading) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      await DatabaseHelper.instance.insertMeter({
        'meter_name': name,
        'opening_reading': openingReading,
        'latest_reading': openingReading,
      });
      await loadMeters();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> renameMeter(String id, String newName) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      await DatabaseHelper.instance.updateMeterName(id, newName);
      await loadMeters();
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> deleteMeter(String id) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      await DatabaseHelper.instance.deleteMeter(id);
      await loadMeters();
    } finally {
      isLoading.value = false;
    }
  }
}
