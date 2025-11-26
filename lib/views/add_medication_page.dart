import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:reminder_app/controllers/add_medication_controller.dart';

class AddMedicationPage extends GetView<AddMedicationController> {
  const AddMedicationPage({super.key});

  static const double appBarHeight = 80.0;
  static const double spacingVertical = 20.0;
  static const double paddingHorizontal = 16.0;
  static const double fontSizeTitle = 22.0;
  static const double fontSizeBody = 16.0;

  @override
  Widget build(BuildContext context) {
    // Listen to error and success messages
    ever(controller.errorMessage, (String? message) {
      if (message != null && message.isNotEmpty) {
        Get.snackbar(
          'Error',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(10),
          borderRadius: 8,
        );
      }
    });

ever(controller.successMessage, (String? message) {
  if (message != null && message.isNotEmpty) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
    );
  }
});


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
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: const [
              Text(
                'Add Medications',
                maxLines: 2,
                softWrap: true,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
        const Text(
          'Medication photo (optional)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: controller.imageFile.value != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: kIsWeb
                          ? Image.network(
                              controller.imageFile.value!.path,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(controller.imageFile.value!.path),
                              fit: BoxFit.cover,
                            ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Color(0xFF42A5F5),
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Add a photo of the medication',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Helps you recognize pills more easily',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    ),
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
          _buildInputFieldWithController(
            label: 'Medication Name *',
            hint: 'e.g., Aspirin',
            controller: controller.nameController,
          ),
          const SizedBox(height: 16.0),
          _buildDosageField(controller),
          const SizedBox(height: 16.0),
          _buildFrequencyDropdown(controller),
          const SizedBox(height: 16.0),
          _buildDurationDropdown(controller),
          const SizedBox(height: 16.0),
          _buildInputFieldWithController(
            label: 'Notes (Optional)',
            hint: 'e.g., Take with food',
            controller: controller.notesController,
            maxLines: 3,
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
            'Dose Times *',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12.0),

          // ✅ Add Time Button with Material time picker
          GestureDetector(
            onTap: () async {
              final selectedTime = await showTimePicker(
                context: Get.context!,
                initialTime: TimeOfDay.now(),
                builder: (BuildContext context, Widget? child) {
                  return MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(alwaysUse24HourFormat: false),
                    child: Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF4FC3F7),
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: Colors.black87,
                        ),
                        timePickerTheme: TimePickerThemeData(
                          backgroundColor: Colors.white,
                          hourMinuteShape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          dayPeriodBorderSide: const BorderSide(
                            color: Color(0xFF4FC3F7),
                            width: 1,
                          ),
                          dayPeriodColor: const Color(0xFF4FC3F7),
                          dayPeriodTextColor: Colors.white,
                          dayPeriodShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          dialHandColor: const Color(0xFF4FC3F7),
                          dialBackgroundColor: Colors.grey[100],
                          hourMinuteTextColor: Colors.black87,
                          hourMinuteColor: const Color(0xFFE3F2FD),
                          dialTextColor: Colors.black87,
                          entryModeIconColor: const Color(0xFF4FC3F7),
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF4FC3F7),
                          ),
                        ),
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit
                              .scaleDown, // ✅ يصغر تلقائياً عشان كل المحتوى يظهر
                          child: child!,
                        ),
                      ),
                    ),
                  );
                },
              );
              if (selectedTime != null) {
                controller.addDoseTime(selectedTime);
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
                children: const [
                  Text(
                    'Add Dose Time',
                    style: TextStyle(fontSize: 14, color: Color(0xFF4FC3F7)),
                  ),
                  Icon(Icons.add_alarm, color: Color(0xFF4FC3F7)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14.0),

          // ✅ Display added dose times
          Obx(() {
            if (controller.doseTimes.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'No dose times added yet',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ),
              );
            }

            return Column(
              children: controller.doseTimes.asMap().entries.map((entry) {
                final index = entry.key;
                final time = entry.value;
                return Padding(
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
                        Expanded(
                          child: Text(
                            controller.formatTimeOfDay(time),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => controller.removeDoseTime(index),
                          icon: const Icon(Icons.close, size: 18),
                          color: Colors.red,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),
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
            : () async {
                final ok = await controller.saveMedication();
                if (ok == true) {
                  controller.resetForm();
                  Get.offAllNamed('/medications');
                }
              },
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

  Widget _buildInputFieldWithController({
    required String label,
    required String hint,
    required TextEditingController controller,
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
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
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
                controller: controller.dosageController,
                keyboardType: TextInputType.number,
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
          'Frequency',
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
            hint: const Text(
              'Select frequency',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF4FC3F7),
            ),
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            items: controller.frequencyOptions
                .where((v) => v != 'Select frequency')
                .map(
                  (v) => DropdownMenuItem(
                    value: v,
                    child: Text(
                      v,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                controller.frequency.value = val;

                final max = controller.maxDoseTimesAllowed;
                if (max > 0 && controller.doseTimes.length > max) {
                  controller.doseTimes.value =
                      controller.doseTimes.take(max).toList();
                }
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
        'Duration of use *',
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
          hint: const Text(
            'Select duration',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF4FC3F7),
          ),
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          items: controller.durationOptions
              .where((v) => v != 'Select duration')
              .map(
                (v) => DropdownMenuItem(
                  value: v,
                  child: Text(
                    v,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
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
