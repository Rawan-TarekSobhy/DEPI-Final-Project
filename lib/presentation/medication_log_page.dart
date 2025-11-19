import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reminder_app/controllers/medication_log_controller.dart';
import 'package:reminder_app/controllers/medication_log_controller.dart';

class MedicationLogPage extends StatelessWidget {
  final controller = Get.put(MedicationLogController());

  MedicationLogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medication Log'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
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
                        children: [
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
                      SizedBox(height: 16),
                      Text(
                        'Overall Adherence',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: controller.adherence.value / 100,
                              minHeight: 7,
                              backgroundColor: Colors.blue[50],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text('${controller.adherence.value.round()}%'),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Column(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green),
                                  SizedBox(height: 2),
                                  Text(
                                    'Taken',
                                    style: TextStyle(color: Colors.green[800]),
                                  ),
                                  Text(
                                    '${controller.takenDoses.value} doses',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Column(
                                children: [
                                  Icon(Icons.cancel, color: Colors.red),
                                  SizedBox(height: 2),
                                  Text(
                                    'Missed',
                                    style: TextStyle(color: Colors.red[800]),
                                  ),
                                  Text(
                                    '${controller.missedDoses.value} doses',
                                    style: TextStyle(
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
              SizedBox(height: 24),
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
                      Text(
                        'Filter Logs',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Medication',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('All Medications'),
                          ),
                        ],
                        onChanged: (value) {},
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: [
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
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.home),
                    onPressed: () => Get.offAllNamed('/home'),
                  ),
                  IconButton(icon: Icon(Icons.medication), onPressed: () {}),
                  IconButton(
                    icon: Icon(Icons.list_alt),
                    color: Colors.blue,
                    onPressed: () {},
                  ),
                  IconButton(icon: Icon(Icons.person), onPressed: () {}),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
