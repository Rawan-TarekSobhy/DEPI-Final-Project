import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:reminder_app/controllers/medication_log_controller.dart';

class MedicationLogPage extends StatelessWidget {
  MedicationLogPage({Key? key}) : super(key: key);

  final MedicationLogController controller =
      Get.put(MedicationLogController());

  static const double appBarHeight = 72.0;
  static const double paddingHorizontal = 14.0;
  static const double spacingVertical = 16.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF64B5F6),
        toolbarHeight: appBarHeight,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF64B5F6), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: paddingHorizontal,
              ),
              child: Row(
                children: const [
                  BackButton(color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Medication Log',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18, // أصغر من قبل
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: SpinKitPumpingHeart(
              color: Color(0xFF4FC3F7),
              size: 32, // أصغر
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: paddingHorizontal,
            vertical: spacingVertical,
          ),
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAdherenceCard(),
              const SizedBox(height: 14),
              _buildFilterCard(),
              const SizedBox(height: 14),
              _buildLogsList(),
            ],
          ),
        );
      }),
    );
  }

  // ================== Cards ==================

  Widget _buildAdherenceCard() {
    return Card(
      elevation: 0.5,
      color: const Color(0xFFEFF6FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.show_chart,
                    color: Color(0xFF4FC3F7), size: 18),
                SizedBox(width: 6),
                Text(
                  'Adherence Summary',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Overall Adherence',
              style: TextStyle(fontSize: 12.5, color: Colors.grey[700]),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => LinearProgressIndicator(
                      value: controller.adherence.value / 100,
                      minHeight: 5,
                      borderRadius: BorderRadius.circular(4),
                      backgroundColor: const Color(0xFFD9E8FF),
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF4FC3F7),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Obx(
                  () => Text(
                    '${controller.adherence.value.round()}%',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _buildTakenCard()),
                const SizedBox(width: 10),
                Expanded(child: _buildMissedCard()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTakenCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE6F8EC),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(height: 2),
          const Text(
            'Taken',
            style: TextStyle(color: Colors.green, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Obx(
            () => Text(
              '${controller.takenDoses.value} doses',
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissedCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDE7E9),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          const Icon(Icons.cancel, color: Colors.red, size: 18),
          const SizedBox(height: 2),
          const Text(
            'Missed',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Obx(
            () => Text(
              '${controller.missedDoses.value} doses',
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Logs',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: _inputDecoration('Medication'),
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
              decoration: _inputDecoration('Status'),
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
    );
  }

  Widget _buildLogsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ================== Shared ==================

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12.5),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFF4FC3F7), width: 1.8),
      ),
    );
  }
}
