import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bill_details_controller.dart';

class BillDetailsScreen extends StatelessWidget {
  const BillDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final Map<String, dynamic> args = Get.arguments ?? {};
    final int billId = args['billId'] ?? 0;
    final Map<String, dynamic>? billMap = args['bill'];

    final actualBillId = billMap != null ? billMap['id'] : billId;
    final String monthYear = billMap != null
        ? billMap['month_year']
        : (args['monthYear'] ?? 'Unknown Month');
    final double globalCostPerUnit = billMap != null
        ? billMap['total_cost_per_unit']
        : 0.0;

    final BillDetailsController controller = Get.put(
      BillDetailsController(billId: actualBillId),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: BackButton(color: colorScheme.onSurface),
        title: Text(
          'Invoice Summary',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
            fontSize: 20,
          ),
        ),
        actions: [
          Obx(() {
            if (controller.isLoading.value || controller.records.isEmpty) {
              return const SizedBox.shrink();
            }

            double totalAmountDue = 0.0;
            double totalConsumption = 0.0;
            for (var r in controller.records) {
              totalAmountDue += r['amount'] ?? 0.0;
              totalConsumption += r['consumption'] ?? 0.0;
            }

            return IconButton(
              icon: Icon(Icons.share, color: colorScheme.primary),
              tooltip: 'Share as Image',
              onPressed: () {
                final shareWidget = _buildShareWidget(
                  monthYear,
                  totalAmountDue,
                  totalConsumption,
                  globalCostPerUnit,
                  controller,
                );
                controller.shareBillAsImage(context, shareWidget);
              },
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.records.isEmpty) {
          return Center(
            child: Text(
              'No records found for this bill.',
              style: TextStyle(color: colorScheme.onSurface.withAlpha(140)),
            ),
          );
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
              Text(
                '$monthYear Invoice',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Billing Cycle: $monthYear',
                style: TextStyle(
                  color: colorScheme.onSurface.withAlpha(160),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),

              // Total Bill Summary Card (intentionally always dark blue)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'TOTAL AMOUNT DUE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${totalAmountDue.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Consumption',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              '${totalConsumption.toStringAsFixed(1)} kWh',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Cost per Unit',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              '₹${globalCostPerUnit.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Meter-wise Usage Breakdown',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),

              // Line Items
              ...controller.records
                  .where(
                    (r) =>
                        r['consumption'] > 0 || controller.records.length == 1,
                  )
                  .map((r) {
                    final mName =
                        controller.meters[r['meter_id']] ?? 'Unknown Meter';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: isDark
                            ? Border.all(color: const Color(0xFF334155))
                            : null,
                        boxShadow: isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withAlpha(8),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                mName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                '₹${(r['amount'] ?? 0.0).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: colorScheme.primary,
                                ),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildDetailColumn(
                                context,
                                'Previous Reading',
                                '${r['previous_reading']}',
                              ),
                              _buildDetailColumn(
                                context,
                                'Current Reading',
                                '${r['current_reading']}',
                              ),
                              _buildDetailColumn(
                                context,
                                'Usage',
                                '${r['consumption']} kWh',
                                isHighlight: true,
                              ),
                            ],
                          ),
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

  Widget _buildDetailColumn(
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
            color: isHighlight
                ? const Color(0xFF059669)
                : colorScheme.onSurface,
            fontWeight: isHighlight ? FontWeight.w900 : FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildShareWidget(
    String monthYear,
    double totalAmount,
    double totalUsage,
    double globalCost,
    BillDetailsController controller,
  ) {
    // Share widget is always light (for image export)
    return Theme(
      data: ThemeData.light(),
      child: Material(
        color: Colors.white,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Bill On $monthYear',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount: ₹${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Total Usage: ${totalUsage.toStringAsFixed(1)} kWh',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                DataTable(
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  dataTextStyle: const TextStyle(color: Colors.black),
                  columnSpacing: 16,
                  horizontalMargin: 0,
                  showBottomBorder: true,
                  columns: const [
                    DataColumn(label: Text('Meter')),
                    DataColumn(label: Text('Prev')),
                    DataColumn(label: Text('Cur')),
                    DataColumn(label: Text('Usg')),
                    DataColumn(label: Text('Amt(₹)')),
                  ],
                  rows: controller.records
                      .where(
                        (r) =>
                            (r['consumption'] ?? 0) > 0 ||
                            controller.records.length == 1,
                      )
                      .map((r) {
                        final mName =
                            controller.meters[r['meter_id']] ?? 'Unknown';
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                mName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            DataCell(Text('${r['previous_reading']}')),
                            DataCell(Text('${r['current_reading']}')),
                            DataCell(Text('${r['consumption']}')),
                            DataCell(
                              Text((r['amount'] ?? 0.0).toStringAsFixed(2)),
                            ),
                          ],
                        );
                      })
                      .toList(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
