import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  static const _keyDefaultUnitPrice = 'default_unit_price';

  final defaultUnitPrice = 0.0.obs;
  final priceEditController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble(_keyDefaultUnitPrice) ?? 0.0;
    defaultUnitPrice.value = saved;
    priceEditController.text = saved > 0 ? saved.toString() : '';
  }

  Future<void> saveDefaultUnitPrice(double price) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyDefaultUnitPrice, price);
    defaultUnitPrice.value = price;
    Get.snackbar(
      'Saved',
      'Default unit price set to Rs. $price/kWh',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFDCFCE7),
      colorText: const Color(0xFF14532D),
    );
  }

  void showEditPriceDialog(BuildContext context) {
    // Pre-fill with current value
    priceEditController.text =
        defaultUnitPrice.value > 0 ? defaultUnitPrice.value.toString() : '';

    Get.defaultDialog(
      contentPadding: const EdgeInsets.all(16),
      title: 'Default Unit Price',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Set the default cost per unit (Rs./kWh). This will auto-fill in both Single and Bulk entry forms.',
            style: TextStyle(fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: priceEditController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Price (Rs./kWh)',
              prefixText: 'Rs. ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
      textConfirm: 'Save',
      textCancel: 'Cancel',
      onConfirm: () {
        final val = double.tryParse(priceEditController.text.trim()) ?? 0.0;
        if (val > 0) {
          saveDefaultUnitPrice(val);
        }
        Get.back();
      },
    );
  }

  @override
  void onClose() {
    priceEditController.dispose();
    super.onClose();
  }
}
