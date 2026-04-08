import 'package:get/get.dart';
import '../db/database_helper.dart';

class HomeController extends GetxController {
  final billingHistory = <Map<String, dynamic>>[].obs;
  final meters = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final totalBilled = 0.0.obs;
  final totalConsumption = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;
    final bHistory = await DatabaseHelper.instance.getBillingHistory();
    billingHistory.value = bHistory;

    final mList = await DatabaseHelper.instance.getAllMeters();
    meters.value = mList;

    final db = await DatabaseHelper.instance.getMonthlyReports();
    
    double tBilled = 0.0;
    double tCons = 0.0;
    
    for (var report in db) {
      tBilled += (report['total_amount'] as num?)?.toDouble() ?? 0.0;
      tCons += (report['total_consumption'] as num?)?.toDouble() ?? 0.0;
    }

    totalBilled.value = tBilled;
    totalConsumption.value = tCons;

    isLoading.value = false;
  }
}
