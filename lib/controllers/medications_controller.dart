import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

class MedicationsController extends GetxController {
  final medications = <Medication>[].obs;
  final nextDoseTimes = <int, String>{}.obs;

  final editDoseTimes = <TimeOfDay>[].obs;
  final editFrequency = ''.obs;

  final isLoading = false.obs;

  final AuthService authService = Get.find<AuthService>();
  final connectivityService = Get.find<ConnectivityService>();
  final medicationsService = Get.find<MedicationsService>();
  final schedulesService = Get.find<SchedulesService>();
  final recordsService = Get.find<RecordsService>();

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
        final schedules = await database.medicationScheduleDao.getSchedulesByMedId(med.medId!);
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
    if (med.medId == null) return;

    final isOnline = await connectivityService.connected();

    if (isOnline) {
      try {
        await medicationsService.deleteMedicationFromSupabase(med.medId!);

        try {
          final notificationService = NotificationService();
          await notificationService.cancelMedicationNotifications(med.medId!);
        } catch (_) {}

        await database.medicationsDao.hardDeleteMedication(med.medId!);
      } catch (e) {
        print('Delete Error: $e');
      }
      await database.medicationsDao.markAsDeleted(med.medId!, 'not_synced');
    } else {
      try {
        final notificationService = NotificationService();
        await notificationService.cancelMedicationNotifications(med.medId!);
      } catch (_) {}

      await database.medicationsDao.markAsDeleted(med.medId!, 'not_synced');
    }

    if (med.medId != null) nextDoseTimes.remove(med.medId);
    await loadMedications();

    Get.snackbar(
      'Deleted',
      '${med.name} removed',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4FC3F7),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
    );
  }

  Future<void> loadScheduleForEdit(Medication med) async {
    editDoseTimes.clear();
    editFrequency.value = med.frequency;
    if (med.medId == null) return;

    final schedules = await database.medicationScheduleDao.getSchedulesByMedId(med.medId!);
    for (final s in schedules) {
      final parts = s.intakeTime.split(':');
      if (parts.length != 2) continue;
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h != null && m != null) {
        editDoseTimes.add(TimeOfDay(hour: h, minute: m));
      }
    }
    _sortEditDoseTimes();
  }

  void onEditFrequencyChanged(String? newValue) {
    if (newValue == null) return;
    editFrequency.value = newValue;

    if (editDoseTimes.isEmpty) return;
    if (newValue == 'As needed') return;

    final firstTime = editDoseTimes.first;
    _regenerateEditSchedule(startTime: firstTime);
  }

  void addDoseTimeForEdit(TimeOfDay time) {
    if (editFrequency.value == 'As needed') {
      final exists = editDoseTimes.any((t) => t.hour == time.hour && t.minute == time.minute);
      if (!exists) {
        editDoseTimes.add(time);
        _sortEditDoseTimes();
      }
    } else {
      _regenerateEditSchedule(startTime: time);
    }
  }

  void _regenerateEditSchedule({required TimeOfDay startTime}) {
    editDoseTimes.clear();
    int count = maxDoseTimesAllowedForEdit;

    if (count <= 0) return;

    if (count == 1) {
      editDoseTimes.add(startTime);
      return;
    }

    int interval = 24 ~/ count;
    final now = DateTime.now();
    DateTime base = DateTime(now.year, now.month, now.day, startTime.hour, startTime.minute);

    for (int i = 0; i < count; i++) {
      DateTime next = base.add(Duration(hours: i * interval));
      editDoseTimes.add(TimeOfDay.fromDateTime(next));
    }
    _sortEditDoseTimes();
  }

  void removeDoseTimeForEdit(int index) {
    if (index >= 0 && index < editDoseTimes.length) {
      editDoseTimes.removeAt(index);
    }
  }

  void _sortEditDoseTimes() {
    editDoseTimes.sort((a, b) {
      final aM = a.hour * 60 + a.minute;
      final bM = b.hour * 60 + b.minute;
      return aM.compareTo(bM);
    });
  }

  Future<void> saveEditedSchedule(Medication med) async {
    if (med.medId == null) return;

    int expectedCount = maxDoseTimesAllowedForEdit;
    if (expectedCount > 0 && editDoseTimes.length != expectedCount) {
      Get.snackbar(
        'Error',
        'Frequency is set to $expectedCount times, but you have ${editDoseTimes.length} times set.\nPlease add the missing time.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    isLoading.value = true;

    try {
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
        isDeleted: med.isDeleted,
      );

      await database.medicationsDao.updateMedication(updated);

      final isOnline = await connectivityService.connected();
      if (isOnline) {
        try {
          await schedulesService.deleteSchedulesForMedFromSupabase(med.medId!);
          await medicationsService.updateMedicationOnSupabase(updated);
          await database.medicationsDao.updateMedicationSyncStatus(updated.medId!, 'synced');
        } catch (e) {
          print('Supabase update failed: $e');
        }
      }

      await database.medicationScheduleDao.deleteSchedulesByMedId(med.medId!);
      for (final t in editDoseTimes) {
        await database.medicationScheduleDao.insertSchedule(MedicationSchedule(
          scheduleId: null,
          medId: med.medId!,
          intakeTime: formatTimeForDB(t),
          syncStatus: 'not_synced',
        ));
      }

      if (isOnline) {
        try {
          final savedSchedules = await database.medicationScheduleDao.getSchedulesByMedId(med.medId!);
          if (savedSchedules.isNotEmpty) {
            await schedulesService.addSchedulesToSupabase(savedSchedules);
            for (final s in savedSchedules) {
              await database.medicationScheduleDao.updateSyncStatus(s.scheduleId!, 'synced');
            }
          }
        } catch (_) {}
      }

      await updateIntakeRecordsForEditedSchedule(med.medId!, med.durationOfUse);

      try {
        final notificationService = NotificationService();
        final allMeds = await database.medicationsDao.getMedicationsByUser(med.userId);
        final updatedMed = allMeds.firstWhere(
              (m) => m.medId == med.medId,
          orElse: () => updated,
        );
        await notificationService.rescheduleMedicationNotifications(updatedMed);
      } catch (e) {
        print('Notif reschedule failed: $e');
      }

      await loadMedications();

      Get.back();

      Get.snackbar(
        'Updated',
        'Schedule for ${med.name} updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4FC3F7),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(10),
        borderRadius: 8,
      );

    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateIntakeRecordsForEditedSchedule(int medId, String durationOfUse) async {
    final isOnline = await connectivityService.connected();

    final allRecords = await database.intakeRecordDao.getRecordsByMedId(medId);

    if (allRecords.isEmpty) return;

    allRecords.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    final firstRecord = allRecords.first;
    final startDate = DateTime.parse(firstRecord.scheduledAt);
    final startDay = DateTime(startDate.year, startDate.month, startDate.day);

    final today = DateTime.now();
    final currentDay = DateTime(today.year, today.month, today.day);
    final daysPassed = currentDay.difference(startDay).inDays;

    final totalDays = durationInDays(durationOfUse);
    final remainingDays = totalDays - daysPassed;

    final pendingRecords = allRecords.where((r) => r.status == 'pending').toList();

    final notificationService = NotificationService();
    for (final r in pendingRecords) {
      if (r.recordId != null) {
        try {
          await notificationService.cancelNotification(r.recordId!);
        } catch (_) {}
      }
    }

    if (isOnline && pendingRecords.isNotEmpty) {
      try {
        for (final r in pendingRecords) {
          if (r.recordId != null) {
            await recordsService.deleteRecordByIdFromSupabase(r.recordId!);
          }
        }
      } catch (e) {
        print('Failed to delete pending records from Supabase: $e');
      }
    }

    for (final r in pendingRecords) {
      await database.intakeRecordDao.deleteRecord(r);
    }

    if (remainingDays <= 0) return;

    final List<IntakeRecord> newRecords = [];

    for (int d = 0; d < remainingDays; d++) {
      final day = currentDay.add(Duration(days: d));

      for (final t in editDoseTimes) {
        final scheduled = DateTime(
          day.year,
          day.month,
          day.day,
          t.hour,
          t.minute,
        );

        if (scheduled.isBefore(DateTime.now())) continue;

        newRecords.add(
          IntakeRecord(
            recordId: null,
            medId: medId,
            scheduledAt: scheduled.toIso8601String(),
            takenAt: null,
            status: 'pending',
            syncStatus: 'not_synced',
          ),
        );
      }
    }

    if (newRecords.isNotEmpty) {
      await database.intakeRecordDao.insertRecords(newRecords);

      if (isOnline) {
        try {
          final savedRecords = await database.intakeRecordDao.getRecordsByMedId(medId);
          final newlyCreatedRecords = savedRecords
              .where((r) => r.status == 'pending' && r.syncStatus == 'not_synced')
              .toList();

          if (newlyCreatedRecords.isNotEmpty) {
            await recordsService.addRecordsToSupabase(newlyCreatedRecords);

            for (final r in newlyCreatedRecords) {
              if (r.recordId != null) {
                await database.intakeRecordDao.updateSyncStatus(r.recordId!, 'synced');
              }
            }
          }
        } catch (e) {
          print('Failed to sync new records: $e');
        }
      }
    }
  }

  String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
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

  String formatTimeForDB(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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

  int get maxDoseTimesAllowedForEdit {
    switch (editFrequency.value) {
      case 'Once daily': return 1;
      case 'Twice daily (2x/day)': return 2;
      case 'Three times daily (3x/day)': return 3;
      case 'Four times daily (4x/day)': return 4;
      case 'As needed': return 0;
      default: return 0;
    }
  }
}