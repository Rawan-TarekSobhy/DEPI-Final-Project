import 'dart:async';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:reminder_app/core/init_local_db.dart';
import 'package:reminder_app/data/entity/intake_records.dart';
import 'package:reminder_app/data/entity/medications.dart';
import 'package:reminder_app/services/auth_service.dart';

class HomeController extends GetxController {
  var currentTime = "".obs;
  var currentDate = "".obs;
  Timer? timer;
  var greeting = ''.obs;

  // جرعات اليوم
  final todaysRecords = <IntakeRecord>[].obs;
  final todaysMeds = <Medication>[].obs; // نفس الترتيب بتاع records
  final isLoading = false.obs;

  late final AuthService authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    _updateTime();
    timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _updateTime();
    });
    loadTodayDoses();
  }

void _updateTime() {
  final now = DateTime.now();
  currentTime.value = DateFormat('hh:mm a').format(now);
  currentDate.value = DateFormat('EEEE, MMMM d').format(now);

  final hour = now.hour;
  if (hour < 12) {
    greeting.value = 'Good morning';
  } else if (hour < 18) {
    greeting.value = 'Good afternoon';
  } else {
    greeting.value = 'Good evening';
  }
}

  Future<void> loadTodayDoses() async {
    final userId = authService.currentUserId;
    if (userId == null || userId.isEmpty) return;

    isLoading.value = true;
    try {
      // 1) أدوية اليوزر
      final meds = await database.medicationsDao.getMedicationsByUser(userId);
      final Map<int, Medication> medsById = {
        for (final m in meds.where((m) => m.medId != null)) m.medId!: m,
      };

      // 2) records لليوم فقط
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = start
          .add(const Duration(days: 1))
          .subtract(const Duration(milliseconds: 1));

      final all = await database.intakeRecordDao.getRecordsBetweenDates(
        start.toIso8601String(),
        end.toIso8601String(),
      );

      all.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

      final recs = <IntakeRecord>[];
      final medsList = <Medication>[];

      for (final r in all) {
        final med = medsById[r.medId];
        if (med == null) continue;
        recs.add(r);
        medsList.add(med);
      }

      todaysRecords.assignAll(recs);
      todaysMeds.assignAll(medsList);
    } finally {
      isLoading.value = false;
    }
  }

  // ===== تحديث الحالة =====

  Future<void> markAsTaken(IntakeRecord record) async {
    if (record.status == 'taken') return;

    final updated = IntakeRecord(
      recordId: record.recordId,
      medId: record.medId,
      scheduledAt: record.scheduledAt,
      takenAt: DateTime.now().toIso8601String(),
      status: 'taken',
      syncStatus: 'not_synced',
    );

    await database.intakeRecordDao.updateRecord(updated);

    final index = todaysRecords.indexWhere(
      (r) => r.recordId == record.recordId,
    );
    if (index != -1) {
      todaysRecords[index] = updated;
      todaysRecords.refresh();
    }
  }

  Future<void> markAsMissed(IntakeRecord record) async {
    if (record.status == 'missed') return;

    final updated = IntakeRecord(
      recordId: record.recordId,
      medId: record.medId,
      scheduledAt: record.scheduledAt,
      takenAt: record.takenAt,
      status: 'missed',
      syncStatus: 'not_synced',
    );

    await database.intakeRecordDao.updateRecord(updated);

    final index = todaysRecords.indexWhere(
      (r) => r.recordId == record.recordId,
    );
    if (index != -1) {
      todaysRecords[index] = updated;
      todaysRecords.refresh();
    }
  }

  // ===== Helpers =====

  String formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour < 12 ? 'AM' : 'PM';
      return '$hour12:$minute $period';
    } catch (_) {
      return iso;
    }
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }
}
