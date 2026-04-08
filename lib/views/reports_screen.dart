import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reports_controller.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatelessWidget {
  final ReportsController controller = Get.put(ReportsController());

  ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Reports & Statements',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.loadReports,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            children: [
              // Lifetime Summary Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3A8A).withAlpha(50),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Revenue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${controller.lifetimeBilled.value.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Total Energy',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${controller.lifetimeConsumption.value.toStringAsFixed(1)} kWh',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
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
              // Filters
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Filter Meter',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.selectedMeterId.value,
                          isExpanded: true,
                          isDense: true,
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('All Meters'),
                            ),
                            ...controller.allMeters.map(
                              (m) => DropdownMenuItem(
                                value: m['id'] as String,
                                child: Text(m['meter_name'].toString()),
                              ),
                            ),
                          ],
                          onChanged: controller.setMeterFilter,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.grey, width: 0),
                        ),
                        elevation: 1,
                      ),
                      onPressed: () async {
                        final range = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                          initialDateRange: controller.startDate.value != null
                              ? DateTimeRange(
                                  start: controller.startDate.value!,
                                  end: controller.endDate.value!,
                                )
                              : null,
                        );
                        if (range != null) {
                          controller.setDateFilter(range.start, range.end);
                        }
                      },
                      icon: const Icon(Icons.calendar_month, size: 18),
                      label: Text(
                        controller.startDate.value == null
                            ? 'Select Dates'
                            : '${DateFormat('MMM dd').format(controller.startDate.value!)} - ${DateFormat('MMM dd').format(controller.endDate.value!)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Obx(
                        () => Checkbox(
                          value: controller.showLatestOnly.value,
                          activeColor: const Color(0xFF1E3A8A),
                          onChanged: (val) =>
                              controller.toggleLatestOnly(val ?? false),
                        ),
                      ),
                      const Text(
                        'Latest entry per meter',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (controller.startDate.value != null ||
                      controller.selectedMeterId.value != null ||
                      !controller.showLatestOnly.value)
                    TextButton.icon(
                      onPressed: controller.clearFilters,
                      icon: const Icon(Icons.clear, size: 14),
                      label: const Text('Clear Filters'),
                    ),
                ],
              ),

              const SizedBox(height: 24),
              const Text(
                'Detailed Ledger',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),

              if (controller.filteredReports.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No records match the selected filters.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                      dataRowMinHeight: 40,
                      dataRowMaxHeight: 50,
                      columnSpacing: 24,
                      columns: const [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Meter')),
                        DataColumn(label: Text('Prev Unit')),
                        DataColumn(label: Text('Cur Unit')),
                        DataColumn(label: Text('Usg (kWh)')),
                        DataColumn(label: Text('Amt (₹)')),
                      ],
                      rows: controller.filteredReports.map((report) {
                        final date = DateTime.fromMillisecondsSinceEpoch(
                          report['created_at'],
                        );
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(DateFormat('MMM dd, yy').format(date)),
                            ),
                            DataCell(Text(report['meter_name'].toString())),
                            DataCell(
                              Text(
                                (report['previous_reading'] as num)
                                    .toStringAsFixed(1),
                              ),
                            ),
                            DataCell(
                              Text(
                                (report['current_reading'] as num)
                                    .toStringAsFixed(1),
                              ),
                            ),
                            DataCell(
                              Text(
                                (report['consumption'] as num).toStringAsFixed(
                                  1,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                (report['amount'] as num).toStringAsFixed(2),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
