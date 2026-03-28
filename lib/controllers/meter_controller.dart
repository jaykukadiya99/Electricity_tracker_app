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
    await DatabaseHelper.instance.insertMeter({
      'meter_name': name,
      'opening_reading': openingReading,
      'latest_reading': openingReading,
    });
    await loadMeters();
  }

  Future<void> renameMeter(int id, String newName) async {
    await DatabaseHelper.instance.updateMeterName(id, newName);
    await loadMeters();
  }
  
  Future<void> deleteMeter(int id) async {
    await DatabaseHelper.instance.deleteMeter(id);
    await loadMeters();
  }
}
