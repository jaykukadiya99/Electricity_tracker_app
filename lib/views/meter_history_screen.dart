import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/meter_history_controller.dart';

class MeterHistoryScreen extends StatelessWidget {
  const MeterHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final int meterId = args['meter_id'] ?? 0;

    final MeterHistoryController controller = Get.put(MeterHistoryController(meterId: meterId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Obx(() => Text(controller.meterData['meter_name'] ?? 'Meter History', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return Column(
          children: [
            // Overview Summary Map
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard('Total Cost', '₹${controller.totalCost.value.toStringAsFixed(2)}', Icons.payments, Colors.blue),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard('Total Usage', '${controller.totalConsumption.value.toStringAsFixed(1)} kWh', Icons.bolt, Colors.orange),
                  ),
                ],
              ),
            ),
            
            // Latest Reading Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              color: const Color(0xFF1E3A8A),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('LATEST READING', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                  Text('${controller.meterData['latest_reading'] ?? 0.0} kWh', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                ],
              ),
            ),
            
            // Table Header Data
            Expanded(
              child: controller.historyRecords.isEmpty 
                  ? const Center(child: Text('No billing history found for this meter.', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.historyRecords.length,
                      itemBuilder: (context, index) {
                        final record = controller.historyRecords[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.black.withAlpha(10))),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(record['month_year'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                                    Text('₹${(record['amount'] ?? 0.0).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E3A8A))),
                                  ],
                                ),
                                const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildDetailCol('Previous', '${record['previous_reading']}'),
                                    _buildDetailCol('Current', '${record['current_reading']}'),
                                    _buildDetailCol('Usage', '${record['consumption']} kWh', isHighlight: true),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }
  
  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildDetailCol(String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(
          color: isHighlight ? const Color(0xFF059669) : const Color(0xFF0F172A),
          fontWeight: isHighlight ? FontWeight.w900 : FontWeight.bold, 
          fontSize: 13
        )),
      ],
    );
  }
}
