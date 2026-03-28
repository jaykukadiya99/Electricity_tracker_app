import 'package:get/get.dart';
import '../db/database_helper.dart';

class BillDetailsController extends GetxController {
  final int billId;
  final isLoading = true.obs;
  final records = <Map<String, dynamic>>[].obs;
  final meters = <int, String>{}.obs;

  BillDetailsController({required this.billId});

  @override
  void onInit() {
    super.onInit();
    loadDetails();
  }

  Future<void> loadDetails() async {
    isLoading.value = true;
    final allMeters = await DatabaseHelper.instance.getAllMeters();
    for (var m in allMeters) {
      meters[m['id']] = m['meter_name'];
    }

    final data = await DatabaseHelper.instance.getBillingRecords(billId);
    records.value = data;
    isLoading.value = false;
  }
}
