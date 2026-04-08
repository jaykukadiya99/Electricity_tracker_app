import 'package:get/get.dart';
import '../db/database_helper.dart';

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
    final activeRecords = records.where((r) => (r['consumption'] ?? 0.0) > 0).toList();
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
}
