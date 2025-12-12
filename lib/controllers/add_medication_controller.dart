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
import 'package:reminder_app/services/notification_service.dart';
import 'package:reminder_app/services/schedules_service.dart';
import 'package:reminder_app/services/records_service.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../services/language_service.dart';
import 'navigation_controller.dart';

class AddMedicationController extends GetxController {
  late final AuthService authService = Get.find<AuthService>();
  late final ConnectivityService connectivityService = Get.find<ConnectivityService>();
  late final MedicationsService medicationsService = Get.find<MedicationsService>();
  late final SchedulesService schedulesService = Get.find<SchedulesService>();
  late final RecordsService recordsService = Get.find<RecordsService>();

  final picker = ImagePicker();
  final SpeechToText speech = SpeechToText();
  final language = LanguageService();

  final nameController = TextEditingController();
  final dosageController = TextEditingController();
  final notesController = TextEditingController();

  final frequency = 'Select frequency'.obs;
  final duration = 'Select duration'.obs;

  final imageFile = Rx<XFile?>(null);
  final isListening = false.obs;
  final isLoading = false.obs;

  final errorMessage = RxnString();

  final doseTimes = <TimeOfDay>[].obs;

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
      case 'Once daily': return 1;
      case 'Twice daily (2x/day)': return 2;
      case 'Three times daily (3x/day)': return 3;
      case 'Four times daily (4x/day)': return 4;
      case 'As needed': return 0;
      default: return 0;
    }
  }

  int durationInDays(String value) {
    switch (value) {
      case '7 days': return 7;
      case '14 days': return 14;
      case '30 days': return 30;
      case '90 days': return 90;
      case 'Ongoing': return 90;
      default: return 30;
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
    isLoading.value = false;
  }

  // ====== Logic: Frequency Change (Auto-Schedule) ======
  void onFrequencyChanged(String? newValue) {
    if (newValue == null) return;
    frequency.value = newValue;
    errorMessage.value = null;

    if (doseTimes.isEmpty) return;
    if (newValue == 'As needed') return;

    final firstTime = doseTimes.first;
    _regenerateAutoSchedule(startTime: firstTime);
  }

  // ====== Logic: Add Dose Time ======
  void addDoseTime(TimeOfDay time) {
    if (frequency.value == 'Select frequency') {
      if (doseTimes.isEmpty) {
        doseTimes.add(time);
      } else {
        doseTimes[0] = time;
      }
      return;
    }

    if (frequency.value == 'As needed') {
      final exists = doseTimes.any((t) => t.hour == time.hour && t.minute == time.minute);
      if (!exists) {
        doseTimes.add(time);
        _sortDoseTimes();
      }
    } else {
      _regenerateAutoSchedule(startTime: time);
    }
  }

  void _regenerateAutoSchedule({required TimeOfDay startTime}) {
    doseTimes.clear();
    int count = maxDoseTimesAllowed;
    if (count <= 0) return;

    if (count == 1) {
      doseTimes.add(startTime);
      return;
    }

    int interval = 24 ~/ count;
    final now = DateTime.now();
    DateTime base = DateTime(now.year, now.month, now.day, startTime.hour, startTime.minute);

    for (int i = 0; i < count; i++) {
      DateTime next = base.add(Duration(hours: i * interval));
      doseTimes.add(TimeOfDay.fromDateTime(next));
    }
    _sortDoseTimes();
  }

  void removeDoseTime(int index) {
    if (index >= 0 && index < doseTimes.length) {
      doseTimes.removeAt(index);
    }
  }

  void _sortDoseTimes() {
    doseTimes.sort((a, b) {
      final aMinutes = a.hour * 60 + a.minute;
      final bMinutes = b.hour * 60 + b.minute;
      return aMinutes.compareTo(bMinutes);
    });
  }

  // ====== Image Logic ======
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

  Future<String?> saveImageLocally(XFile imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
      final localPath = '${directory.path}/$fileName';
      await File(imageFile.path).copy(localPath);
      return localPath;
    } catch (e) {
      errorMessage.value = 'Error saving image: $e';
      return null;
    }
  }

  // ====== Speech Logic ======
  Future<void> toggleNameListening() async {
    if (!isListening.value) {
      final available = await speech.initialize();
      if (available) {
        isListening.value = true;
        speech.listen(
          onResult: (result) => nameController.text = result.recognizedWords,
          localeId: language.isEnglish() ? 'en-US':'ar-EG'  ,
        );
      }
    } else {
      isListening.value = false;
      await speech.stop();
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

    if (double.tryParse(dosageController.text) == null) {
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

    int expectedCount = maxDoseTimesAllowed;
    if (expectedCount > 0 && doseTimes.length != expectedCount) {
      if (doseTimes.isNotEmpty) {
        _regenerateAutoSchedule(startTime: doseTimes.first);
      } else {
        errorMessage.value = 'Please add a dose time';
        return false;
      }
    }

    if (doseTimes.isEmpty) {
      errorMessage.value = 'Please add at least one dose time';
      return false;
    }

    return true;
  }

  // ====== Save Medication ======
  Future<void> saveMedication() async {
    errorMessage.value = null;

    if (!validateInputs()) return;

    final userId = authService.currentUserId;
    if (userId == null) {
      Get.offAllNamed('/login');
      return;
    }

    isLoading.value = true;

    try {
      // 1. Save Image
      String? localImagePath;
      if (imageFile.value != null) {
        localImagePath = await saveImageLocally(imageFile.value!);
      }

      // 2. Insert Medication (Local)
      final newMed = Medication(
        userId: userId,
        name: nameController.text.trim(),
        dosage: '${dosageController.text} mg',
        frequency: frequency.value,
        durationOfUse: duration.value,
        notes: notesController.text.trim(),
        imageUrl: localImagePath,
        syncStatus: 'not_synced',
        isDeleted: 'false',
      );

      await database.medicationsDao.insertMedication(newMed);
      final insertedMed = (await database.medicationsDao.getMedicationsByUser(userId)).last;

      // 3. Insert Schedules (Local)
      for (final time in doseTimes) {
        await database.medicationScheduleDao.insertSchedule(MedicationSchedule(
            scheduleId: null,
            medId: insertedMed.medId!,
            intakeTime: formatTimeForDB(time),
            syncStatus: 'not_synced'
        ));
      }

      // 4. Insert Records (Local) - with NULL IDs
      final days = durationInDays(duration.value);
      final today = DateTime.now();
      final List<IntakeRecord> recordsToInsert = [];
      for (int d = 0; d < days; d++) {
        final day = DateTime(today.year, today.month, today.day).add(Duration(days: d));
        for (final t in doseTimes) {
          final scheduled = DateTime(day.year, day.month, day.day, t.hour, t.minute);
          recordsToInsert.add(IntakeRecord(
            recordId: null,
            medId: insertedMed.medId!,
            scheduledAt: scheduled.toIso8601String(),
            status: 'pending',
            syncStatus: 'not_synced',
          ));
        }
      }
      await database.intakeRecordDao.insertRecords(recordsToInsert);

      // 🛑 الخطوة المصيرية (بتاعتك): بنجيب الـ Records تاني عشان يبقى فيها IDs
      final savedRecords = await database.intakeRecordDao.getRecordsByMedId(insertedMed.medId!);

      // 5. Notifications (Using savedRecords)
      try {
        await NotificationService().scheduleAllNotificationsForMedication(
            insertedMed, savedRecords.map((r) => r.recordId!).toList()
        );
      } catch (e) {
        print("Notif Error: $e");
      }

      // ===========================================
      // 🚀 Exit Strategy: Stop UI & Close Page
      // ===========================================

      isLoading.value = false;
      resetForm();

      Get.back(); // 1. Close Add Page

      // 2. Navigate to Home
      if (Get.isRegistered<NavigationController>()) {
        final navController = Get.find<NavigationController>();
        navController.navigateToIndex(0);
      }

      // 3. Show Success Snackbar
      Get.snackbar(
        'Success',
        'Medication added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4FC3F7),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
        borderRadius: 8,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

      // ===========================================
      // ☁️ Background Sync (Safe Mode)
      // ===========================================

      // بنعمل الـ Sync في الخلفية عشان الصفحة متقفش
      // وبنستخدم savedRecords عشان نتفادى الكراش
      _syncToSupabaseSafe(insertedMed, userId, savedRecords);

    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Error saving medication: $e';
    }
  }

  // دالة منفصلة للمزامنة الآمنة (Fire and Forget)
  Future<void> _syncToSupabaseSafe(Medication med, String userId, List<IntakeRecord> savedRecords) async {
    try {
      if (await connectivityService.connected()) {
        // Sync Med
        await medicationsService.addMedicationToSupabase(med: med, userId: userId);
        await database.medicationsDao.updateMedicationSyncStatus(med.medId!, 'synced');

        // Sync Schedules
        final savedSchedules = await database.medicationScheduleDao.getSchedulesByMedId(med.medId!);
        await schedulesService.addSchedulesToSupabase(savedSchedules);
        for(var s in savedSchedules) {
          await database.medicationScheduleDao.updateSyncStatus(s.scheduleId!, 'synced');
        }

        // Sync Records
        await recordsService.addRecordsToSupabase(savedRecords);

        // 🛑 التعديل بتاعك هنا: Loop على savedRecords اللي فيها IDs
        for(var r in savedRecords) {
          if (r.recordId != null) {
            await database.intakeRecordDao.updateSyncStatus(r.recordId!, 'synced');
          }
        }
      }
    } catch (e) {
      print("Background Sync Error: $e");
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    dosageController.dispose();
    notesController.dispose();
    speech.cancel();
    super.onClose();
  }
}