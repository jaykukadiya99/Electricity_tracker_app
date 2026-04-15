import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/new_bill_controller.dart';

class NewBillScreen extends StatelessWidget {
  final NewBillController controller = Get.put(NewBillController());

  // Local state for UI dropdown selection
  late final Rx<String?> selectedMeterId;

  NewBillScreen({super.key}) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String? mId = args['meter_id'];
    selectedMeterId = Rx<String?>(mId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: BackButton(color: colorScheme.onSurface),
        title: Row(
          children: [
            Icon(Icons.bar_chart, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'UtilityFlow',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: colorScheme.onSurface.withAlpha(180)),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() {
        if (controller.meters.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final selectedMeterObj = selectedMeterId.value != null
            ? controller.meters.firstWhereOrNull(
                (m) => m['id'] == selectedMeterId.value,
              )
            : null;
        final latestReading = selectedMeterObj != null
            ? selectedMeterObj['latest_reading']
            : 0.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'DATA ENTRY',
                style: TextStyle(
                  color: colorScheme.onSurface.withAlpha(130),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Monthly Reading',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 24),

              // Entry Form Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: isDark ? Border.all(color: const Color(0xFF334155)) : null,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Billing Cycle (Date)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => controller.selectDate(context),
                      child: AbsorbPointer(
                        child: TextField(
                          controller: controller.monthYearController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(
                              Icons.calendar_today,
                              color: colorScheme.onSurface.withAlpha(140),
                            ),
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Select Meter',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: isDark ? Border.all(color: const Color(0xFF334155)) : null,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: Text(
                            'Choose a meter...',
                            style: TextStyle(color: colorScheme.onSurface.withAlpha(140)),
                          ),
                          value: selectedMeterId.value,
                          dropdownColor: theme.cardColor,
                          items: controller.meters.map((m) {
                            return DropdownMenuItem<String>(
                              value: m['id'],
                              child: Text(
                                m['meter_name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            selectedMeterId.value = val;
                            if (val != null) {
                              controller.onMeterSelected(val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Current Reading (kWh)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller.currentReadingController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        hintText: '0.00',
                      ),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colorScheme.onSurface,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (val) {
                        if (selectedMeterId.value != null) {
                          controller.setCurrentReading(selectedMeterId.value!, val);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Previous: $latestReading kWh',
                      style: TextStyle(
                        color: colorScheme.onSurface.withAlpha(120),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Cost per Unit (₹)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'e.g. 8.5',
                      ),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colorScheme.onSurface,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: controller.setCostPerUnit,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Standard Rate: ₹8.00',
                      style: TextStyle(
                        color: colorScheme.onSurface.withAlpha(120),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: selectedMeterId.value != null
                            ? () => controller.saveBill()
                            : null,
                        icon: const Icon(Icons.save, size: 18),
                        label: const Text(
                          'Record Monthly Entry',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }
}
