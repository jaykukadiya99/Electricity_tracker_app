import 'package:get/get.dart';
import '../db/database_helper.dart';

class AppController extends GetxController {
  final _isSetupComplete = false.obs;
  bool get isSetupComplete => _isSetupComplete.value;
  
  final _isLoading = true.obs;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    checkSetupStatus();
  }

  Future<void> checkSetupStatus() async {
    _isLoading.value = true;
    _isSetupComplete.value = await DatabaseHelper.instance.isSetupComplete();
    _isLoading.value = false;
  }
}
