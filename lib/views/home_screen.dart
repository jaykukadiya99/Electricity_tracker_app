import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Faint grey background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.bar_chart, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('ElecTrack', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontSize: 20)),
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
              radius: 16,
              backgroundImage: NetworkImage('https://i.pravatar.cc/100'), // Placeholder avatar
            ),
          )
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TOTAL BILLED PERIOD', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      Text(
                        controller.billingHistory.isNotEmpty ? '\$14,284.50' : '\$0.00',
                        style: const TextStyle(color: Color(0xFF0F172A), fontSize: 36, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.trending_down, color: Colors.green[600], size: 16),
                          const SizedBox(width: 4),
                          Text('4.2% from last month', style: TextStyle(color: Colors.green[600], fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.receipt, size: 18),
                              label: const Text('Generate\nReports', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3A8A), // Dark blue
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF1F5F9), // Light grey
                                foregroundColor: const Color(0xFF0F172A),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                elevation: 0,
                              ),
                              child: const Text('Details', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Consumption Deep Blue Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B213E), // Dark Navy
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('TOTAL CONSUMPTION', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
                          Icon(Icons.bolt, color: Colors.blue[300]),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            controller.billingHistory.isNotEmpty ? '842,000' : '${controller.totalConsumption.value}',
                            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(width: 8),
                          const Text('kWh', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Fake Bar Chart
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildBar(40, Colors.white24),
                          _buildBar(60, Colors.white24),
                          _buildBar(50, Colors.white24),
                          _buildBar(70, Colors.white24),
                          _buildBar(90, Colors.white54),
                          _buildBar(80, const Color(0xFFA7F3D0)), // Light green active bar
                          _buildBar(65, Colors.white24),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Peak Usage: 14:00', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const Text('Efficiency: 92%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Three Status Cards
                _buildStatusCard(Icons.water_drop, const Color(0xFFA7F3D0), const Color(0xFF059669), 'WATER SUPPLY', 'Stable Status'),
                const SizedBox(height: 12),
                _buildStatusCard(Icons.ac_unit, const Color(0xFFBAE6FD), const Color(0xFF0284C7), 'HVAC LOAD', '+12% vs Avg'),
                const SizedBox(height: 12),
                _buildStatusCard(Icons.warning_amber_rounded, const Color(0xFFDBEAFE), const Color(0xFF1D4ED8), 'MAINTENANCE', '2 Pending Tasks'),
                
                const SizedBox(height: 32),
                
                // Meter Analytics Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Meter Analytics', style: TextStyle(color: Color(0xFF0F172A), fontSize: 20, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text('Individual consumption and billing status', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      ],
                    ),
                    Text('View All\nMeters  →', textAlign: TextAlign.right, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 20),

                // Meter List
                controller.meters.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: Text("No meters configured yet.", style: TextStyle(color: Colors.grey))),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.meters.length,
                        itemBuilder: (context, index) {
                          final meter = controller.meters[index];
                          // Dummy calculations just to match the visual vibe of the reference UI
                          String status = index % 3 == 0 ? 'PAID' : (index % 3 == 1 ? 'OVERDUE' : 'PENDING');
                          Color statusColor = status == 'PAID' ? const Color(0xFF059669) : (status == 'OVERDUE' ? Colors.red : const Color(0xFF1D4ED8));
                          Color statusBg = statusColor.withAlpha(20);
                          double progress = status == 'PAID' ? 0.8 : (status == 'OVERDUE' ? 1.0 : 0.4);
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4)),
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
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(Icons.business, color: Color(0xFF0F172A), size: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(meter['meter_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                            Text('Latest unit', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
                                      child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Current Bill', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                    Text(status == 'PAID' ? '\$1,240.00' : (status == 'OVERDUE' ? '\$3,892.15' : '\$845.50'), style: TextStyle(fontWeight: FontWeight.bold, color: status == 'OVERDUE' ? Colors.red : Colors.black, fontSize: 14)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: const Color(0xFFF1F5F9),
                                    color: status == 'OVERDUE' ? Colors.red : Theme.of(context).primaryColor,
                                    minHeight: 6,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Last reading: ${meter['latest_reading']} kWh', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                                    Text('Usage: ${ (progress * 100).toInt() }% Capacity', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      
                const SizedBox(height: 80), // Padding for the floating action button to not block content
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 4,
        onPressed: () async {
          await Get.toNamed('/new_bill');
          controller.loadDashboardData();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBar(double height, Color color) {
    return Container(
      width: 32,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
      ),
    );
  }

  Widget _buildStatusCard(IconData icon, Color iconBg, Color iconColor, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.2, color: Color(0xFF64748B))),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
            ],
          )
        ],
      ),
    );
  }
}
