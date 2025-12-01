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
import 'package:reminder_app/services/connectivity_service.dart';
import 'package:reminder_app/services/medications_service.dart';
import 'package:reminder_app/services/schedules_service.dart';
import 'package:reminder_app/services/records_service.dart';

class AddMedicationController extends GetxController {
  late final AuthService authService = Get.find<AuthService>();
  late final ConnectivityService connectivityService = Get.find<ConnectivityService>();
  late final MedicationsService medicationsService = Get.find<MedicationsService>();
  late final SchedulesService schedulesService = Get.find<SchedulesService>();
  late final RecordsService recordsService = Get.find<RecordsService>();

  final picker = ImagePicker();

  final nameController = TextEditingController();
  final dosageController = TextEditingController();
  final notesController = TextEditingController();

  final frequency = 'Select frequency'.obs;
  final duration = 'Select duration'.obs;

  final imageFile = Rx<XFile?>(null);

  final isLoading = false.obs;

  
  final errorMessage = RxnString();
  final successMessage = RxnString();

  final doseTimes = <TimeOfDay>[].obs;

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
        return 0; 
      default:
        return 0;
    }
  }

  int durationInDays(String value) {
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
        return 90; 
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
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      imageFile.value = image;
      return true;
    }
    return false;
  }

  Future<bool> takeImageFromCamera() async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
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
  bool validateInputs() {
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
  Future<String?> saveImageLocally(XFile imageFile) async {
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

    if (!validateInputs()) {
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
      // 1. Save image if exists
      if (imageFile.value != null) {
        localImagePath = await saveImageLocally(imageFile.value!);
      }

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
        isDeleted: 'false',
      );

      await database.medicationsDao.insertMedication(newMedication);

      final meds =
          await database.medicationsDao.getMedicationsByUser(userId);
      final insertedMed = meds.last;


      // 5. Save schedules locally
      for (final time in doseTimes) {
        final schedule = MedicationSchedule(
          scheduleId: null,
          medId: insertedMed.medId!,
          intakeTime: formatTimeForDB(time),
          syncStatus: 'not_synced',
        );
        await database.medicationScheduleDao.insertSchedule(schedule);
      }

      final savedSchedules = await database.medicationScheduleDao
          .getSchedulesByMedId(insertedMed.medId!);


      // 6. Generate intake_records locally
      final days = durationInDays(duration.value);
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

      final savedRecords = await database.intakeRecordDao
          .getRecordsByMedId(insertedMed.medId!);


      final connected = await connectivityService.connected();

      if (connected) {
        try {
          // Sync Medication
          await medicationsService.addMedicationToSupabase(
            med: insertedMed,
            userId: userId,
          );
          await database.medicationsDao.updateMedicationSyncStatus(
            insertedMed.medId!,
            'synced',
          );

          await schedulesService.addSchedulesToSupabase(savedSchedules);
          for (final s in savedSchedules) {
            await database.medicationScheduleDao.updateSyncStatus(
              s.scheduleId!,
              'synced',
            );
          }

          await recordsService.addRecordsToSupabase(savedRecords);
          for (final r in savedRecords) {
            await database.intakeRecordDao.updateSyncStatus(
              r.recordId!,
              'synced',
            );
          }

          successMessage.value = 'Medication added successfully';
        } catch (e) {
          successMessage.value =
              'Medication added locally. Will sync when online.';
        }
      } 

      return true;
    } catch (e) {
      errorMessage.value = 'Error saving medication: $e';
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
