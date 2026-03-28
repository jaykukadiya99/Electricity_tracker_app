import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/meter_setup_controller.dart';

class MeterSetupScreen extends StatelessWidget {
  final MeterSetupController controller = Get.put(MeterSetupController());

  MeterSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // App Logo placeholder
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.electric_bolt, size: 64, color: Color(0xFF1E3A8A)),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Welcome to ElecTrack',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Let\'s set up your property profile.\nHow many meters do you want to track?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              // Form Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Number of Meters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller.meterCountController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        hintText: 'e.g. 5',
                        prefixIcon: const Icon(Icons.numbers, color: Color(0xFF64748B)),
                      ),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'We will auto-generate base entries (Meter 1, Meter 2, etc.) for you. You can rename them later in the dashboard.',
                      style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic, height: 1.5),
                    ),
                    const SizedBox(height: 32),
                    Obx(() => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value ? null : () => controller.proceedToReadings(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A), // Dark blue
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              elevation: 0,
                            ),
                            child: controller.isLoading.value 
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Initialize Setup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
