import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/meter_controller.dart';

class MetersScreen extends StatelessWidget {
  final MeterController controller = Get.put(MeterController());

  MetersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Manage Meters', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.meters.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.electrical_services, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text('No meters found.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                const Text('Add a meter to start tracking usage.', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.meters.length,
          itemBuilder: (context, index) {
            final meter = controller.meters[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withAlpha(20),
                  child: Icon(Icons.speed, color: Theme.of(context).primaryColor),
                ),
                title: Text(meter['meter_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Latest reading: ${meter['latest_reading']} kWh'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_chart, color: Colors.green),
                      tooltip: 'Add Reading',
                      onPressed: () async {
                        await Get.toNamed('/new_bill', arguments: {'meter_id': meter['id']});
                        controller.loadMeters();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showRenameDialog(context, meter['id'], meter['meter_name']),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context, meter['id'], meter['meter_name']),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Meter', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final readingController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Meter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Meter Name (e.g. Shop 1)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: readingController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Opening Reading (kWh)', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && readingController.text.isNotEmpty) {
                final reading = double.tryParse(readingController.text) ?? 0.0;
                controller.addMeter(nameController.text.trim(), reading);
                Get.back();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, int id, String currentName) {
    final nameController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Meter'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'New Name', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                controller.renameMeter(id, nameController.text.trim());
                Get.back();
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }
  
  void _confirmDelete(BuildContext context, int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meter'),
        content: Text('Are you sure you want to delete "$name"? All associated billing records will also be deleted.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              controller.deleteMeter(id);
              Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
