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

    final db = await DatabaseHelper.instance.database;
    final sumResult = await db.rawQuery('SELECT SUM(amount) as total_amount, SUM(consumption) as total_consumption FROM BillingRecords');
    
    double tBilled = 0.0;
    double tCons = 0.0;
    
    if (sumResult.isNotEmpty) {
      tBilled = (sumResult.first['total_amount'] as num?)?.toDouble() ?? 0.0;
      tCons = (sumResult.first['total_consumption'] as num?)?.toDouble() ?? 0.0;
    }

    totalBilled.value = tBilled;
    totalConsumption.value = tCons;

    isLoading.value = false;
  }
}
