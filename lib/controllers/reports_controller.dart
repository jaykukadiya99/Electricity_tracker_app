import 'package:get/get.dart';
import '../db/database_helper.dart';

class ReportsController extends GetxController {
  final filteredReports = <Map<String, dynamic>>[].obs;
  final allMeters = <Map<String, dynamic>>[].obs;
  
  final isLoading = true.obs;
  
  final lifetimeBilled = 0.0.obs;
  final lifetimeConsumption = 0.0.obs;

  // Filters
  final selectedMeterId = Rx<int?>(null);
  final startDate = Rx<DateTime?>(null);
  final endDate = Rx<DateTime?>(null);
  final showLatestOnly = true.obs; // Default per user request

  @override
  void onInit() {
    super.onInit();
    loadDependencies();
  }

  Future<void> loadDependencies() async {
    isLoading.value = true;
    allMeters.value = await DatabaseHelper.instance.getAllMeters();
    await loadReports();
  }

  Future<void> loadReports() async {
    isLoading.value = true;
    
    int? startMs = startDate.value?.millisecondsSinceEpoch;
    // End date should include the whole day (up to 23:59:59)
    int? endMs = endDate.value?.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1)).millisecondsSinceEpoch;
    
    final reportsList = await DatabaseHelper.instance.getFilteredReports(
      meterId: selectedMeterId.value,
      startDate: startMs,
      endDate: endMs,
      isLatestOnly: showLatestOnly.value,
    );
    
    filteredReports.value = reportsList;

    double tempBilled = 0.0;
    double tempCons = 0.0;

    for (var report in reportsList) {
      tempBilled += (report['amount'] as num?)?.toDouble() ?? 0.0;
      tempCons += (report['consumption'] as num?)?.toDouble() ?? 0.0;
    }
    
    lifetimeBilled.value = tempBilled;
    lifetimeConsumption.value = tempCons;

    isLoading.value = false;
  }

  void setMeterFilter(int? meterId) {
    selectedMeterId.value = meterId;
    loadReports();
  }

  void setDateFilter(DateTime? start, DateTime? end) {
    startDate.value = start;
    endDate.value = end;
    loadReports();
  }

  void toggleLatestOnly(bool value) {
    showLatestOnly.value = value;
    loadReports();
  }

  void clearFilters() {
    selectedMeterId.value = null;
    startDate.value = null;
    endDate.value = null;
    showLatestOnly.value = true;
    loadReports();
  }
}
