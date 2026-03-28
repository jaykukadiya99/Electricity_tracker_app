import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/meter_initial_readings_controller.dart';

class MeterInitialReadingsScreen extends StatelessWidget {
  const MeterInitialReadingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final int count = args['count'] ?? 0;

    // Use Get.put to initialize controller with given count
    final MeterInitialReadingsController controller = Get.put(MeterInitialReadingsController(count: count));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text('Initial Readings', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontSize: 20)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: controller.count,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.speed, color: Color(0xFF1E3A8A), size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Meter ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                              const SizedBox(height: 4),
                              Text('Opening Reading (kWh)', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            controller: controller.readingsControllers[index],
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              filled: true,
                              fillColor: const Color(0xFFF1F5F9),
                            ),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, -4)),
                ],
              ),
              child: Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: controller.isLoading.value ? null : () => controller.saveMeters(),
                      icon: const Icon(Icons.check_circle_outline, size: 20),
                      label: const Text('Complete Setup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A), // Dark blue
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 0,
                      ),
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
