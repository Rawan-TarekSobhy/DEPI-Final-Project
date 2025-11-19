import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reminder_app/controllers/medication_log_controller.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MedicationLogPage extends StatelessWidget {
  final controller = Get.put(MedicationLogController());

  MedicationLogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Log'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: SpinKitPumpingHeart(color: Color(0xFF4FC3F7), size: 50),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.show_chart, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Adherence Summary',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Overall Adherence',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: controller.adherence.value / 100,
                              minHeight: 7,
                              backgroundColor: Colors.blue[50],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text('${controller.adherence.value.round()}%'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Taken',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                  Text(
                                    '${controller.takenDoses.value} doses',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Column(
                                children: [
                                  const Icon(Icons.cancel, color: Colors.red),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Missed',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  Text(
                                    '${controller.missedDoses.value} doses',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filter Logs',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Medication',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('All Medications'),
                          ),
                        ],
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('All Status'),
                          ),
                        ],
                        onChanged: (value) {},
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: () => Get.offAllNamed('/home'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.medication),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.list_alt),
                    color: Colors.blue,
                    onPressed: () {},
                  ),
                  IconButton(icon: const Icon(Icons.person), onPressed: () {}),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
