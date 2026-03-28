import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bill_details_controller.dart';

class BillDetailsScreen extends StatelessWidget {
  const BillDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final int billId = args['billId'] ?? 0;
    final Map<String, dynamic>? billMap = args['bill'];
    
    final actualBillId = billMap != null ? billMap['id'] : billId;
    final String monthYear = billMap != null ? billMap['month_year'] : (args['monthYear'] ?? 'Unknown Month');
    final double globalCostPerUnit = billMap != null ? billMap['total_cost_per_unit'] : 0.0;

    final BillDetailsController controller = Get.put(BillDetailsController(billId: actualBillId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text('Invoice Summary', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontSize: 20)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.records.isEmpty) {
          return const Center(child: Text('No records found for this bill.', style: TextStyle(color: Colors.grey)));
        }

        double totalAmountDue = 0.0;
        double totalConsumption = 0.0;

        for (var r in controller.records) {
          totalAmountDue += r['amount'] ?? 0.0;
          totalConsumption += r['consumption'] ?? 0.0;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text('$monthYear Invoice', style: const TextStyle(color: Color(0xFF0F172A), fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('Billing Cycle: $monthYear', style: const TextStyle(color: Color(0xFF475569), fontSize: 13)),
              const SizedBox(height: 24),
              
              // Total Bill Summary Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    const Text('TOTAL AMOUNT DUE', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Text('₹${totalAmountDue.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Consumption', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            Text('${totalConsumption.toStringAsFixed(1)} kWh', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Cost per Unit', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            Text('₹${globalCostPerUnit.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              const Text('Meter-wise Usage Breakdown', style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              
              // Line Items
              ...controller.records.where((r) => r['consumption'] > 0 || controller.records.length == 1).map((r) {
                final mName = controller.meters[r['meter_id']] ?? 'Unknown Meter';
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(mName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                          Text('₹${(r['amount'] ?? 0.0).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E3A8A))),
                        ],
                      ),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Color(0xFFF1F5F9))),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDetailColumn('Previous Reading', '${r['previous_reading']}'),
                          _buildDetailColumn('Current Reading', '${r['current_reading']}'),
                          _buildDetailColumn('Usage', '${r['consumption']} kWh', isHighlight: true),
                        ],
                      )
                    ],
                  ),
                );
              }),
              
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDetailColumn(String label, String value, {bool isHighlight = false}) {
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
