import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/new_bill_controller.dart';

class NewBillScreen extends StatelessWidget {
  final NewBillController controller = Get.put(NewBillController());
  
  // Local state for UI dropdown selection
  late final Rx<int?> selectedMeterId;

  NewBillScreen({super.key}) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final int? mId = args['meter_id'];
    selectedMeterId = Rx<int?>(mId);
  }

  @override
  Widget build(BuildContext context) {
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
        ],
      ),
      body: Obx(() {
        if (controller.meters.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final selectedMeterObj = selectedMeterId.value != null 
            ? controller.meters.firstWhereOrNull((m) => m['id'] == selectedMeterId.value)
            : null;
        final latestReading = selectedMeterObj != null ? selectedMeterObj['latest_reading'] : 0.0;
        final curRead = selectedMeterId.value != null 
            ? (controller.currentReadings[selectedMeterId.value] ?? latestReading) 
            : latestReading;
        final estimatedConsumption = (curRead - latestReading) > 0 ? (curRead - latestReading) : 0.0;
        final totalBillEst = estimatedConsumption * controller.costPerUnit.value;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('DATA ENTRY', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.5)),
              const SizedBox(height: 4),
              const Text('Monthly Reading', style: TextStyle(color: Color(0xFF0F172A), fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 24),

              // Entry Form Card
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
                    const Text('Billing Cycle (Date)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => controller.selectDate(context),
                      child: AbsorbPointer(
                        child: TextField(
                          controller: controller.monthYearController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            filled: true,
                            fillColor: const Color(0xFFF1F5F9),
                            prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF64748B)),
                          ),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    const Text('Select Meter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          hint: const Text('Choose a meter...'),
                          value: selectedMeterId.value,
                          items: controller.meters.map((m) {
                            return DropdownMenuItem<int>(
                              value: m['id'],
                              child: Text(m['meter_name'], style: const TextStyle(fontWeight: FontWeight.w600)),
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
                    
                    const Text('Current Reading (kWh)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller.currentReadingController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        hintText: '0.00',
                      ),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (val) {
                        if (selectedMeterId.value != null) {
                          controller.setCurrentReading(selectedMeterId.value!, val);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Text('Previous: $latestReading kWh', style: const TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 20),
                    
                    const Text('Cost per Unit (₹)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        hintText: 'e.g. 8.5',
                      ),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: controller.setCostPerUnit,
                    ),
                    const SizedBox(height: 8),
                    const Text('Standard Rate: ₹8.00', style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: selectedMeterId.value != null ? () => controller.saveBill() : null,
                        icon: const Icon(Icons.save, size: 18),
                        label: const Text('Record Monthly Entry', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A), // Dark blue
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Feature Preview Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF064E3B), // Dark Teal
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withAlpha(20), borderRadius: BorderRadius.circular(4)),
                      child: const Text('FEATURE PREVIEW', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ),
                    const SizedBox(height: 16),
                    const Text('Smart PDF Receipts', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const Text('Automate your billing workflow. Soon you\'ll be able to generate professional PDF invoices and send them directly to tenants via email.', 
                      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(color: Colors.white.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.picture_as_pdf, color: Colors.white54),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(color: Colors.white.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.email, color: Colors.white54),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Bill Preview Title
              const Text('BILL PREVIEW', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
              const SizedBox(height: 16),
              
              // Bill Preview Card
              Container(
                padding: const EdgeInsets.all(20),
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
                    const Text('ESTIMATED CONSUMPTION', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.2)),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('$estimatedConsumption', style: const TextStyle(color: Color(0xFF059669), fontSize: 32, fontWeight: FontWeight.w900)),
                        const SizedBox(width: 8),
                        const Text('kWh', style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(value: 0.6, backgroundColor: const Color(0xFFF1F5F9), color: const Color(0xFF059669), minHeight: 4),
                    ),
                    const SizedBox(height: 6),
                    const Text('+12% VS LAST MONTH', style: TextStyle(color: Color(0xFF64748B), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    
                    const SizedBox(height: 24),
                    
                    // Total Bill Dark Box
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: const Color(0xFF1E3A8A), borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TOTAL BILL AMOUNT', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.2)),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text('₹', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 4),
                              Text('${totalBillEst.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Processing Status', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                                child: const Text('PENDING', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Line Items
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Meter Name', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                        Text(selectedMeterObj != null ? selectedMeterObj['meter_name'] : '—', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Color(0xFFF1F5F9))),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Unit Rate', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                        Text('₹${controller.costPerUnit.value.toStringAsFixed(2)}/kWh', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Color(0xFFF1F5F9))),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Fixed Service Fee', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                        const Text('₹0.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Efficiency Insight
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: Color(0xFFA7F3D0), shape: BoxShape.circle),
                      child: const Icon(Icons.lightbulb, color: Color(0xFF059669), size: 20),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Efficiency Insight', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                          SizedBox(height: 4),
                          Text('This reading is tracking normally. Continue monitoring meter stability.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, height: 1.5)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }
}
