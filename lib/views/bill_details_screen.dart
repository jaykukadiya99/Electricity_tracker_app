import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bill_details_controller.dart';

class BillDetailsScreen extends StatelessWidget {
  const BillDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final int billId = args['billId'] ?? 0;
    final String monthYear = args['monthYear'] ?? 'Unknown Month';

    // We instantiate the controller with the billId
    final BillDetailsController controller = Get.put(BillDetailsController(billId: billId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Row(
          children: [
            Icon(Icons.bar_chart, color: Color(0xFF1E3A8A)),
            SizedBox(width: 8),
            Text('UtilityFlow', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF475569)),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Color(0xFF1E3A8A),
              child: Text('JD', style: TextStyle(color: Colors.white, fontSize: 10)),
            ),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // We get the first meter from records to display at the top, or just use a generic name
        String primaryMeterName = 'Various Meters';
        double totalAmountDue = 0.0;
        double totalConsumption = 0.0;

        if (controller.records.isNotEmpty) {
          primaryMeterName = controller.meters[controller.records[0]['meter_id']] ?? 'Unknown Meter';
          for (var r in controller.records) {
            totalAmountDue += r['amount'] ?? 0.0;
            totalConsumption += r['consumption'] ?? 0.0;
          }
        }

        // Mock parameters to fill the UI
        final double rate = controller.records.isNotEmpty && controller.records[0]['consumption'] > 0 
           ? (controller.records[0]['amount'] / controller.records[0]['consumption']) 
           : 0.14;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Breadcrumbs
              Row(
                children: [
                  const Text('METERS', style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const Icon(Icons.chevron_right, size: 14, color: Color(0xFF64748B)),
                  Text(primaryMeterName.toUpperCase(), style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const Icon(Icons.chevron_right, size: 14, color: Color(0xFF64748B)),
                  const Text('BILLING DETAIL', style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ],
              ),
              const SizedBox(height: 16),
              
              // Title
              Text('$monthYear Invoice', style: const TextStyle(color: Color(0xFF0F172A), fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              
              // Subtitle
              Text('Meter: $primaryMeterName • Billing Cycle: $monthYear', style: const TextStyle(color: Color(0xFF475569), fontSize: 13)),
              const SizedBox(height: 24),
              
              // Download Statement Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('DOWNLOAD STATEMENT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A), // Dark blue
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Consumption Summary Card
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFA7F3D0), borderRadius: BorderRadius.circular(12)),
                              child: const Text('PAID', style: TextStyle(color: Color(0xFF059669), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            ),
                            const SizedBox(height: 12),
                            const Text('Consumption\nSummary', style: TextStyle(color: Color(0xFF0F172A), fontSize: 20, fontWeight: FontWeight.w900, height: 1.2)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('TOTAL AMOUNT DUE', style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            const SizedBox(height: 4),
                            Text('\$${totalAmountDue.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF1E3A8A), fontSize: 24, fontWeight: FontWeight.w900)),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Electricity Sub-card
                    _buildUtilityCard(
                      icon: Icons.bolt,
                      title: 'ELECTRICITY',
                      consumption: totalConsumption.toStringAsFixed(1),
                      unit: 'kWh',
                      rate: 'Rate \$${rate.toStringAsFixed(2)} / kWh',
                      subtotal: '\$${totalAmountDue.toStringAsFixed(2)}'
                    ),
                    const SizedBox(height: 16),
                    
                    // Mocked Water Sub-card
                    _buildUtilityCard(
                      icon: Icons.water_drop,
                      title: 'WATER',
                      consumption: '12.4',
                      unit: 'm³',
                      rate: 'Rate \$4.20 / m³',
                      subtotal: '\$52.08'
                    ),
                    const SizedBox(height: 16),
                    
                    // Mocked Gas Sub-card
                    _buildUtilityCard(
                      icon: Icons.local_fire_department,
                      title: 'GAS',
                      consumption: '180',
                      unit: 'Units',
                      rate: 'Rate \$0.68 / Unit',
                      subtotal: '\$122.94'
                    ),
                    const SizedBox(height: 32),
                    
                    // Consumption History (Mock Chart)
                    const Text('Consumption\nHistory', style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildChartColumn('MAY', 30, false),
                        _buildChartColumn('JUN', 45, false),
                        _buildChartColumn('JUL', 60, false),
                        _buildChartColumn('AUG', 75, false),
                        _buildChartColumn('SEP', 55, false),
                        _buildChartColumn('OCT', 80, true),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Past Invoices Head
              const Text('PAST INVOICES', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
              const SizedBox(height: 16),
              
              // Past Invoices Mock List
              _buildPastInvoiceRow('September 2023', 'Paid on Sep 10', '\$216.40'),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Color(0xFFE2E8F0))),
              _buildPastInvoiceRow('August 2023', 'Paid on Aug 15', '\$259.12'),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Color(0xFFE2E8F0))),
              _buildPastInvoiceRow('July 2023', 'Paid on Jul 28', '\$204.68'),
              const SizedBox(height: 16),
              
              // View All History Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF475569),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('VIEW ALL HISTORY', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12)),
                ),
              ),
              const SizedBox(height: 32),
              
              // Smart Savings Insights Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B213E), // Dark Navy
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bolt, color: Colors.blue[300], size: 16),
                        const SizedBox(width: 8),
                        const Text('EFFICIENCY ENGINE', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Smart Savings\nInsights', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1.2)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF10B981).withAlpha(30), borderRadius: BorderRadius.circular(6)),
                      child: const Text('SAVING SOON', style: TextStyle(color: Color(0xFFA7F3D0), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ),
                    const SizedBox(height: 16),
                    Text('We are analyzing unit $primaryMeterName\'s peak consumption hours to provide personalized energy-saving tips.', 
                      style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Line Item Breakdown Header
              const Text('Line Item Breakdown', style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              
              // Table Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(flex: 2, child: Text('SERVICE\nDESCRIPTION', style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                  const Expanded(flex: 1, child: Text('READING\n(START)', textAlign: TextAlign.right, style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                  const Expanded(flex: 1, child: Text('READING\n(END)', textAlign: TextAlign.right, style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFFE2E8F0))),
              
              // Actual data mapped to lines
              ...controller.records.map((r) {
                final mName = controller.meters[r['meter_id']] ?? 'Meter';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(flex: 2, child: Text('$mName\nElectricity\nBase Load', style: const TextStyle(color: Color(0xFF0F172A), fontSize: 12, height: 1.5))),
                      Expanded(flex: 1, child: Text('${r['previous_reading']}\nkWh', textAlign: TextAlign.right, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, height: 1.5))),
                      Expanded(flex: 1, child: Text('${r['current_reading']}\nkWh', textAlign: TextAlign.right, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, height: 1.5))),
                    ],
                  ),
                );
              }).toList(),
              
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
      // Simple floating chat button from the mock
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: const Color(0xFF0F172A),
        onPressed: () {},
        child: const Icon(Icons.email, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildUtilityCard({required IconData icon, required String title, required String consumption, required String unit, required String rate, required String subtotal}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF0F172A), size: 16),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(consumption, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(width: 4),
              Text(unit, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(rate, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              Text(subtotal, style: const TextStyle(color: Color(0xFF1E3A8A), fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildChartColumn(String month, double height, bool isCurrent) {
    return Column(
      children: [
        Container(
          width: 8,
          height: height,
          decoration: BoxDecoration(
            color: isCurrent ? const Color(0xFF1E3A8A) : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(month, style: TextStyle(color: isCurrent ? const Color(0xFF1E3A8A) : const Color(0xFF64748B), fontSize: 9, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPastInvoiceRow(String title, String subtitle, String amount) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: const Color(0xFFA7F3D0).withAlpha(100), shape: BoxShape.circle),
          child: const Icon(Icons.check, color: Color(0xFF059669), size: 12),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
            ],
          ),
        ),
        Text(amount, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
