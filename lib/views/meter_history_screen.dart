import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/meter_history_controller.dart';

class MeterHistoryScreen extends StatelessWidget {
  const MeterHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final Map<String, dynamic> args = Get.arguments ?? {};
    final String meterId = args['meter_id'] ?? '';

    final MeterHistoryController controller =
        Get.put(MeterHistoryController(meterId: meterId));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Obx(() => Text(
              controller.meterData['meter_name'] ?? 'Meter History',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            )),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: BackButton(color: colorScheme.onSurface),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Overview Summary
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: isDark
                    ? const Border(bottom: BorderSide(color: Color(0xFF334155)))
                    : null,
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      'Total Cost',
                      '₹${controller.totalCost.value.toStringAsFixed(2)}',
                      Icons.payments,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      'Total Usage',
                      '${controller.totalConsumption.value.toStringAsFixed(1)} kWh',
                      Icons.bolt,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            // Latest Reading Banner (intentionally always dark blue accent)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              color: const Color(0xFF1E3A8A),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'LATEST READING',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    '${controller.meterData['latest_reading'] ?? 0.0} kWh',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // History Records
            Expanded(
              child: controller.historyRecords.isEmpty
                  ? Center(
                      child: Text(
                        'No billing history found for this meter.',
                        style: TextStyle(
                          color: colorScheme.onSurface.withAlpha(140),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.historyRecords.length,
                      itemBuilder: (context, index) {
                        final record = controller.historyRecords[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : Colors.black.withAlpha(10),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        record['month_year'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '₹${(record['amount'] ?? 0.0).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 20),
                                      color: const Color(0xFFEF4444), // red-500
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      onPressed: () => controller.deleteRecord(record),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Divider(
                                    color: colorScheme.onSurface.withAlpha(20),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildDetailCol(
                                      context,
                                      'Previous',
                                      '${record['previous_reading']}',
                                    ),
                                    _buildDetailCol(
                                      context,
                                      'Current',
                                      '${record['current_reading']}',
                                    ),
                                    _buildDetailCol(
                                      context,
                                      'Usage',
                                      '${record['consumption']} kWh',
                                      isHighlight: true,
                                    ),
                                  ],
                                ),
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

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: const Color(0xFF334155)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurface.withAlpha(150),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCol(
    BuildContext context,
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurface.withAlpha(140),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? const Color(0xFF059669) : colorScheme.onSurface,
            fontWeight: isHighlight ? FontWeight.w900 : FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
