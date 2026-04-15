import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  HomeScreen({super.key});

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
        title: Row(
          children: [
            Icon(Icons.bar_chart, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'ElecTrack',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: theme.textTheme.titleLarge?.color ?? colorScheme.onSurface,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.primary.withAlpha(30),
              child: Icon(Icons.person, color: colorScheme.primary, size: 18),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.loadDashboardData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Total Billed Card
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
                        'TOTAL BILLED PERIOD',
                        style: TextStyle(
                          color: colorScheme.onSurface.withAlpha(130),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${controller.totalBilled.value.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Consumption Deep Blue Card (intentionally always dark)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B213E),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL CONSUMPTION',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Icon(Icons.bolt, color: Colors.blue[300]),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            controller.totalConsumption.value.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'kWh',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Meter Analytics Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meter Analytics',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Individual consumption and billing status',
                          style: TextStyle(
                            color: colorScheme.onSurface.withAlpha(140),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Meter List
                controller.meters.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            "No meters configured yet.",
                            style: TextStyle(color: colorScheme.onSurface.withAlpha(100)),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.meters.length,
                        itemBuilder: (context, index) {
                          final meter = controller.meters[index];
                          const Color statusColor = Color(0xFF059669);
                          final Color statusBg = statusColor.withAlpha(20);

                          return GestureDetector(
                            onTap: () {
                              Get.toNamed(
                                '/meter_history',
                                arguments: {'meter_id': meter['id']},
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(20),
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
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? const Color(0xFF334155)
                                                  : const Color(0xFFF1F5F9),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              Icons.business,
                                              color: colorScheme.onSurface,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                meter['meter_name'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: colorScheme.onSurface,
                                                ),
                                              ),
                                              Text(
                                                'Tracked Unit',
                                                style: TextStyle(
                                                  color: colorScheme.onSurface.withAlpha(120),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusBg,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'ACTIVE',
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Latest Reading',
                                        style: TextStyle(
                                          color: colorScheme.onSurface.withAlpha(140),
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        '${meter['latest_reading']} kWh',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: colorScheme.primary,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        heroTag: 'home_fab',
        backgroundColor: colorScheme.primary,
        elevation: 4,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) {
              final sheetTheme = Theme.of(context);
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: sheetTheme.cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Select Data Entry Method',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: sheetTheme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: sheetTheme.brightness == Brightness.dark
                              ? const Color(0xFF334155)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.person, color: sheetTheme.colorScheme.primary),
                      ),
                      title: Text(
                        'Single Meter Entry',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: sheetTheme.colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        'Add usage for one specific meter',
                        style: TextStyle(
                          fontSize: 12,
                          color: sheetTheme.colorScheme.onSurface.withAlpha(140),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () async {
                        Get.back();
                        await Get.toNamed('/new_bill');
                        controller.loadDashboardData();
                      },
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: sheetTheme.brightness == Brightness.dark
                              ? const Color(0xFF334155)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.list_alt, color: sheetTheme.colorScheme.primary),
                      ),
                      title: Text(
                        'Bulk Entry',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: sheetTheme.colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        'Add readings for all meters at once',
                        style: TextStyle(
                          fontSize: 12,
                          color: sheetTheme.colorScheme.onSurface.withAlpha(140),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () async {
                        Get.back();
                        await Get.toNamed('/bulk_bill');
                        controller.loadDashboardData();
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
