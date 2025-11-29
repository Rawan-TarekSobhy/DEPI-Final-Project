import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reminder_app/core/init_local_db.dart';
import 'package:reminder_app/data/entity/medications.dart';
import 'package:reminder_app/data/entity/medication_schedule.dart';
import 'package:reminder_app/services/auth_service.dart';

class MedicationsController extends GetxController {
  final medications = <Medication>[].obs;

  final nextDoseTimes = <int, String>{}.obs;

  final editDoseTimes = <TimeOfDay>[].obs;
  final editFrequency = ''.obs;
  final isLoading = false.obs;

  late final AuthService authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    loadMedications();
  }

  Future<void> loadMedications() async {
    final userId = authService.currentUserId;
    if (userId == null || userId.isEmpty) return;

    isLoading.value = true;
    try {
      final list = await database.medicationsDao.getMedicationsByUser(userId);
      medications.assignAll(list);

      nextDoseTimes.clear();

      for (final med in list) {
        if (med.medId == null) continue;

        final schedules =
            await database.medicationScheduleDao.getSchedulesByMedId(med.medId!);

        if (schedules.isNotEmpty) {
          schedules.sort((a, b) => a.intakeTime.compareTo(b.intakeTime));
          nextDoseTimes[med.medId!] = schedules.first.intakeTime;
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteMedication(Medication med) async {
    await database.medicationsDao.deleteMedication(med);

    if (med.medId != null) {
      await database.medicationScheduleDao.deleteSchedulesByMedId(med.medId!);
      nextDoseTimes.remove(med.medId);
    }

    await loadMedications();
  }

  Future<void> updateMedication(
    Medication med, {
    required String name,
    required String dosage,
    required String frequency,
    required String duration,
    required String notes,
  }) async {
    final updated = Medication(
      medId: med.medId,
      userId: med.userId,
      name: name,
      dosage: dosage,
      frequency: frequency,
      durationOfUse: duration,
      notes: notes.isNotEmpty ? notes : null,
      imageUrl: med.imageUrl,
      syncStatus: 'not_synced',
    );

    await database.medicationsDao.updateMedication(updated);
    await loadMedications();
  }

  // ================== Edit Schedule (frequency + times) ==================

  Future<void> loadScheduleForEdit(Medication med) async {
    editDoseTimes.clear();
    editFrequency.value = med.frequency;

    if (med.medId == null) return;

    final schedules =
        await database.medicationScheduleDao.getSchedulesByMedId(med.medId!);

    for (final s in schedules) {
      final parts = s.intakeTime.split(':');
      if (parts.length != 2) continue;
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h == null || m == null) continue;
      editDoseTimes.add(TimeOfDay(hour: h, minute: m));
    }

    editDoseTimes.sort((a, b) {
      final aM = a.hour * 60 + a.minute;
      final bM = b.hour * 60 + b.minute;
      return aM.compareTo(bM);
    });
  }

void addDoseTimeForEdit(TimeOfDay time) {
  final max = maxDoseTimesAllowedForEdit;
  if (max > 0 && editDoseTimes.length >= max) {
    Get.snackbar(
      'Limit reached',
      'You can only add $max dose times for this frequency',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return;
  }

  final exists = editDoseTimes.any(
    (t) => t.hour == time.hour && t.minute == time.minute,
  );
  if (!exists) {
    editDoseTimes.add(time);
    editDoseTimes.sort((a, b) {
      final aM = a.hour * 60 + a.minute;
      final bM = b.hour * 60 + b.minute;
      return aM.compareTo(bM);
    });
  }
}

  void removeDoseTimeForEdit(int index) {
    if (index >= 0 && index < editDoseTimes.length) {
      editDoseTimes.removeAt(index);
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

  Future<void> saveEditedSchedule(Medication med) async {
    if (med.medId == null) return;

    isLoading.value = true;
    try {
      // 1) حدّث frequency في medications
      final updated = Medication(
        medId: med.medId,
        userId: med.userId,
        name: med.name,
        dosage: med.dosage,
        frequency: editFrequency.value,
        durationOfUse: med.durationOfUse,
        notes: med.notes,
        imageUrl: med.imageUrl,
        syncStatus: 'not_synced',
      );
      await database.medicationsDao.updateMedication(updated);

      // 2) امسح الـ schedule القديم
      await database.medicationScheduleDao.deleteSchedulesByMedId(med.medId!);

      // 3) اضف الأوقات الجديدة
      for (final t in editDoseTimes) {
        final schedule = MedicationSchedule(
          scheduleId: null,
          medId: med.medId!,
          intakeTime: formatTimeForDB(t),
          syncStatus: 'not_synced',
        );
        await database.medicationScheduleDao.insertSchedule(schedule);
      }

      await loadMedications();
    } finally {
      isLoading.value = false;
    }
  }

  String formatTimeForDisplay(String hhmm) {
    try {
      final parts = hhmm.split(':');
      if (parts.length != 2) return hhmm;
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final dt = DateTime(2020, 1, 1, h, m);
      final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour < 12 ? 'AM' : 'PM';
      return '$hour12:$minute $period';
    } catch (_) {
      return hhmm;
    }
  }

  int get maxDoseTimesAllowedForEdit {
  switch (editFrequency.value) {
    case 'Once daily':
      return 1;
    case 'Twice daily (2x/day)':
      return 2;
    case 'Three times daily (3x/day)':
      return 3;
    case 'Four times daily (4x/day)':
      return 4;
    case 'As needed':
      return 0; // 0 يعني مفيش حد أقصى
    default:
      return 0;
  }
}

}
