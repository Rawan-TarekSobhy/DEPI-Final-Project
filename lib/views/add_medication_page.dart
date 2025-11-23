import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:reminder_app/controllers/add_medication_controller.dart';

class AddMedicationPage extends StatelessWidget {
  const AddMedicationPage({super.key});

  static const double appBarHeight = 80.0;
  static const double spacingVertical = 20.0;
  static const double paddingHorizontal = 16.0;
  static const double fontSizeTitle = 22.0;
  static const double fontSizeBody = 16.0;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddMedicationController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
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
              padding: const EdgeInsets.only(
                top: 10.0,
                left: paddingHorizontal,
                right: paddingHorizontal,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Add Medication',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSizeTitle,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(
                child: SpinKitPumpingHeart(color: Colors.lightBlue, size: 40),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: paddingHorizontal,
                  vertical: spacingVertical,
                ),
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMedicationPhotoCard(controller),
                    const SizedBox(height: spacingVertical),
                    _buildBasicInformationCard(controller),
                    const SizedBox(height: spacingVertical),
                    _buildScheduleTimeCard(controller),
                    const SizedBox(height: spacingVertical),
                    _buildAddButton(controller),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  // ======================= UI Helpers =======================

  Widget _buildMedicationPhotoCard(AddMedicationController controller) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Medication photo (optional)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _showImageSourcePicker(controller),
            child: Obx(
              () => Container(
                width: double.infinity,
                height: 170,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: controller.imageFile.value != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: kIsWeb
                            ? Image.network(
                                controller.imageFile.value!.path,
                                fit: BoxFit.contain,
                              )
                            : Image.file(
                                File(controller.imageFile.value!.path),
                                fit: BoxFit.contain,
                              ),
                      )
                    : _defaultPhotoPlaceholder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultPhotoPlaceholder({String text = 'Tap to add photo'}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.camera_alt, color: Colors.grey[500], size: 28),
        const SizedBox(height: 6),
        Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  void _showImageSourcePicker(AddMedicationController controller) {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Camera'),
                onTap: () {
                  controller.takeImageFromCamera();
                  Get.back();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Gallery'),
                onTap: () {
                  controller.pickImageFromGallery();
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInformationCard(AddMedicationController controller) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Information',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15.0),
          _buildInputField(
            label: 'Medication Name *',
            hint: 'e.g., Aspirin',
            onChanged: (value) => controller.name.value = value,
          ),
          const SizedBox(height: 16.0),
          _buildDosageField(controller),
          const SizedBox(height: 16.0),
          _buildFrequencyDropdown(controller),
          const SizedBox(height: 16.0),
          _buildDurationDropdown(controller),
          const SizedBox(height: 16.0),
          _buildInputField(
            label: 'Notes (Optional)',
            hint: 'e.g., Take with food',
            maxLines: 3,
            onChanged: (value) => controller.notes.value = value,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTimeCard(AddMedicationController controller) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'First Dose Time *',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6.0),
          GestureDetector(
            onTap: () async {
              final selectedTime = await showTimePicker(
                context: Get.context!,
                initialTime: controller.firstDoseTime.value,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF4FC3F7),
                        onPrimary: Colors.white,
                        onSurface: Colors.black87,
                      ),
                      timePickerTheme: const TimePickerThemeData(
                        hourMinuteColor: Color(0xFFE3F2FD),
                        hourMinuteTextColor: Colors.black,
                        dialHandColor: Color(0xFF4FC3F7),
                        dialBackgroundColor: Colors.white,
                      ),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 360),
                        child: FittedBox(fit: BoxFit.scaleDown, child: child!),
                      ),
                    ),
                  );
                },
              );
              if (selectedTime != null) {
                controller.firstDoseTime.value = selectedTime;
                controller.calculateDoseTimes();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => Text(
                      controller.firstDoseTime.value.format(Get.context!),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const Icon(Icons.access_time, color: Color(0xFF4FC3F7)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14.0),
          const Text(
            'Daily dose times (calculated)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6.0),
          Obx(
            () => Column(
              children: controller.dailyDoseTimes
                  .map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.alarm,
                              color: Color(0xFF4FC3F7),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              t,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(AddMedicationController controller) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 44,
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : controller.saveMedication,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4FC3F7),
            disabledBackgroundColor: const Color(0xFF4FC3F7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: controller.isLoading.value
              ? const SpinKitPumpingHeart(color: Colors.white, size: 20)
              : const Text(
                  'Add Medication',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  // ======================= Shared Helpers =======================

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: Padding(padding: const EdgeInsets.all(16.0), child: child),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
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
              borderSide: BorderSide(color: Color(0xFF4FC3F7), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDosageField(AddMedicationController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dosage *',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    controller.dosage.value = double.tryParse(value) ?? 0.0,
                decoration: InputDecoration(
                  hintText: '100',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
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
                    borderSide: BorderSide(color: Color(0xFF4FC3F7), width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Text(
                'mg',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFrequencyDropdown(AddMedicationController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Frequency *',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Obx(
          () => DropdownButtonFormField<String>(
            value: controller.frequency.value == 'Select frequency'
                ? null
                : controller.frequency.value,
            decoration: _dropdownDecoration(),
            hint: Text(
              'Select frequency',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
            items: controller.frequencyOptions
                .map(
                  (v) => DropdownMenuItem(
                    value: v,
                    child: Text(v, style: const TextStyle(fontSize: 13)),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                controller.frequency.value = val;
                controller.calculateDoseTimes();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDurationDropdown(AddMedicationController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Duration of use',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Obx(
          () => DropdownButtonFormField<String>(
            value: controller.duration.value == 'Select duration'
                ? null
                : controller.duration.value,
            decoration: _dropdownDecoration(),
            hint: Text(
              'Select duration',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
            items: controller.durationOptions
                .map(
                  (v) => DropdownMenuItem(
                    value: v,
                    child: Text(v, style: const TextStyle(fontSize: 13)),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                controller.duration.value = val;
              }
            },
          ),
        ),
      ],
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        borderSide: BorderSide(color: Color(0xFF4FC3F7), width: 2),
      ),
    );
  }
}
