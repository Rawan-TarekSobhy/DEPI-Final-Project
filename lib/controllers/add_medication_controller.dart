import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reminder_app/core/init_local_db.dart';
import 'package:reminder_app/data/entity/medications.dart';
import 'package:reminder_app/data/entity/medication_schedule.dart';
import 'package:reminder_app/data/entity/intake_records.dart';
import 'package:reminder_app/services/auth_service.dart';

class AddMedicationController extends GetxController {
  late final AuthService authService = Get.find<AuthService>();
  final ImagePicker _picker = ImagePicker();

  // Text fields
  final nameController = TextEditingController();
  final dosageController = TextEditingController();
  final notesController = TextEditingController();

  // Dropdowns
  final frequency = 'Select frequency'.obs;
  final duration = 'Select duration'.obs;

  // Image
  final Rx<XFile?> imageFile = Rx<XFile?>(null);

  // Loading state
  final isLoading = false.obs;

  // Messages
  final errorMessage = RxnString();
  final successMessage = RxnString();

  // User-added dose times
  final RxList<TimeOfDay> doseTimes = <TimeOfDay>[].obs;

  // Options
  final List<String> frequencyOptions = [
    'Select frequency',
    'Once daily',
    'Twice daily (2x/day)',
    'Three times daily (3x/day)',
    'Four times daily (4x/day)',
    'As needed',
  ];

  final List<String> durationOptions = [
    'Select duration',
    '7 days',
    '14 days',
    '30 days',
    '90 days',
    'Ongoing',
  ];

  // ====== Helpers ======

  int get maxDoseTimesAllowed {
    switch (frequency.value) {
      case 'Once daily':
        return 1;
      case 'Twice daily (2x/day)':
        return 2;
      case 'Three times daily (3x/day)':
        return 3;
      case 'Four times daily (4x/day)':
        return 4;
      case 'As needed':
        return 0; // no limit
      default:
        return 0;
    }
  }

  int _durationInDays(String value) {
    switch (value) {
      case '7 days':
        return 7;
      case '14 days':
        return 14;
      case '30 days':
        return 30;
      case '90 days':
        return 90;
      case 'Ongoing':
        return 90; // مثلاً 3 شهور قدام كبداية
      default:
        return 30;
    }
  }

  void resetForm() {
    nameController.clear();
    dosageController.clear();
    notesController.clear();
    frequency.value = 'Select frequency';
    duration.value = 'Select duration';
    imageFile.value = null;
    doseTimes.clear();
    errorMessage.value = null;
    successMessage.value = null;
    isLoading.value = false;
  }

  // ====== Image ======

  Future<bool> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      imageFile.value = image;
      return true;
    }
    return false;
  }

  Future<bool> takeImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      imageFile.value = image;
      return true;
    }
    return false;
  }

  // ====== Dose times ======

  void addDoseTime(TimeOfDay time) {
    if (maxDoseTimesAllowed > 0 &&
        doseTimes.length >= maxDoseTimesAllowed) {
      errorMessage.value =
          'You can only add $maxDoseTimesAllowed dose times for this frequency.';
      return;
    }

    final exists = doseTimes.any(
      (t) => t.hour == time.hour && t.minute == time.minute,
    );
    if (!exists) {
      doseTimes.add(time);
      doseTimes.sort((a, b) {
        final aMinutes = a.hour * 60 + a.minute;
        final bMinutes = b.hour * 60 + b.minute;
        return aMinutes.compareTo(bMinutes);
      });
    }
  }

  void removeDoseTime(int index) {
    if (index >= 0 && index < doseTimes.length) {
      doseTimes.removeAt(index);
    }
  }

  String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  String formatTimeForDB(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // ====== Validation ======

  bool _validateInputs() {
    if (nameController.text.trim().isEmpty) {
      errorMessage.value = 'Please enter medication name';
      return false;
    }

    final dosageValue = double.tryParse(dosageController.text);
    if (dosageValue == null || dosageValue <= 0) {
      errorMessage.value = 'Please enter a valid dosage';
      return false;
    }

    if (frequency.value == 'Select frequency') {
      errorMessage.value = 'Please select frequency';
      return false;
    }

    if (duration.value == 'Select duration') {
      errorMessage.value = 'Please select duration';
      return false;
    }

    if (doseTimes.isEmpty) {
      errorMessage.value = 'Please add at least one dose time';
      return false;
    }

    return true;
  }

  // ====== Image save ======

  Future<String?> _saveImageLocally(XFile imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
      final localPath = '${directory.path}/$fileName';
      await File(imageFile.path).copy(localPath);
      return localPath;
    } catch (e) {
      errorMessage.value = 'Error saving image: $e';
      return null;
    }
  }

  // ====== Save medication ======

  Future<bool> saveMedication() async {
    // Clear previous messages
    errorMessage.value = null;
    successMessage.value = null;

    if (!_validateInputs()) {
      return false;
    }

    final userId = authService.currentUserId;
    if (userId == null || userId.isEmpty) {
      errorMessage.value = 'User not logged in';
      Get.offAllNamed('/login');
      return false;
    }

    isLoading.value = true;
    String? localImagePath;

    try {
      // Save image if exists
      if (imageFile.value != null) {
        localImagePath = await _saveImageLocally(imageFile.value!);
      }

      // Create medication entity
      final newMedication = Medication(
        userId: userId,
        name: nameController.text.trim(),
        dosage: '${dosageController.text} mg',
        frequency: frequency.value,
        durationOfUse: duration.value,
        notes: notesController.text.trim().isNotEmpty
            ? notesController.text.trim()
            : null,
        imageUrl: localImagePath,
        syncStatus: 'not_synced',
      );

      // Insert medication
      await database.medicationsDao.insertMedication(newMedication);

      // Get inserted med (ببساطة آخر دواء لليوزر)
      final meds =
          await database.medicationsDao.getMedicationsByUser(userId);
      final insertedMed = meds.last;

      // Save schedules (pattern الأوقات في اليوم)
      for (final time in doseTimes) {
        final schedule = MedicationSchedule(
          scheduleId: null,
          medId: insertedMed.medId!,
          intakeTime: formatTimeForDB(time),
          syncStatus: 'not_synced',
        );
        await database.medicationScheduleDao.insertSchedule(schedule);
      }

      // Generate intake_records لكل الأيام حسب duration
      final days = _durationInDays(duration.value);
      final today = DateTime.now();
      final List<IntakeRecord> recordsToInsert = [];

      for (int d = 0; d < days; d++) {
        final day = DateTime(today.year, today.month, today.day)
            .add(Duration(days: d));

        for (final t in doseTimes) {
          final scheduled = DateTime(
            day.year,
            day.month,
            day.day,
            t.hour,
            t.minute,
          );

          recordsToInsert.add(
            IntakeRecord(
              recordId: null,
              medId: insertedMed.medId!,
              scheduledAt: scheduled.toIso8601String(),
              takenAt: null,
              status: 'pending',
              syncStatus: 'not_synced',
            ),
          );
        }
      }

      await database.intakeRecordDao.insertRecords(recordsToInsert);

      successMessage.value = 'Medication added successfully';
      // for (final record in recordsToInsert) {
      //   print(
      //       'Record for medId ${record.medId} at ${record.scheduledAt} with status ${record.status}');
      // }
      return true;
    } catch (e) {
      errorMessage.value = 'Error saving medication: $e';
      print('Save error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ====== Lifecycle ======

  @override
  void onClose() {
    nameController.dispose();
    dosageController.dispose();
    notesController.dispose();

    frequency.value = 'Select frequency';
    duration.value = 'Select duration';
    imageFile.value = null;
    errorMessage.value = null;
    successMessage.value = null;
    doseTimes.clear();
    isLoading.value = false;

    super.onClose();
  }
}
