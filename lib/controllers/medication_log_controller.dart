import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reminder_app/core/init_local_db.dart';
import 'package:reminder_app/data/entity/intake_records.dart';
import 'package:reminder_app/data/entity/medications.dart';
import 'package:reminder_app/services/auth_service.dart';

class MedicationLogController extends GetxController {
  final AuthService authService = Get.find<AuthService>();

  final isLoading = false.obs;

  // كل الـ records المحمّلة
  final RxList<IntakeRecord> records = <IntakeRecord>[].obs;

  // خريطة من medId → Medication
  final RxMap<int, Medication> medsById = <int, Medication>{}.obs;

  // إحصائيات
  final adherence = 0.0.obs;
  final takenDoses = 0.obs;
  final missedDoses = 0.obs;

  // فلاتر
  final selectedMedId = 0.obs; // 0 = All
  final selectedStatus = 'all'.obs; // all / pending / taken / missed

  // رينج الأيام المعروض
  late DateTime fromDate;
  late DateTime toDate;

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    // افتراضيًا: آخر 7 أيام
    fromDate =
        DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
    toDate = DateTime(now.year, now.month, now.day)
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));

    loadLog();
  }

  Future<void> loadLog() async {
    final userId = authService.currentUserId;
    if (userId == null || userId.isEmpty) return;

    isLoading.value = true;
    try {
      // 1) أدوية اليوزر
      final meds = await database.medicationsDao.getMedicationsByUser(userId);
      medsById.value = {
        for (final m in meds.where((m) => m.medId != null)) m.medId!: m,
      };

      // 2) الـ records في الرينج
      final fromIso = fromDate.toIso8601String();
      final toIso = toDate.toIso8601String();
      final all = await database.intakeRecordDao
          .getRecordsBetweenDates(fromIso, toIso);

      // 3) تحويل pending القديمة إلى missed + ترتيب
      final normalized = await _normalizePendingToMissed(all);

      records.assignAll(normalized);
      _recalculateStats();
    } finally {
      isLoading.value = false;
    }
  }

  // تحوّل أي pending ويومها عدى إلى missed، وترتب من الأحدث للأقدم
  Future<List<IntakeRecord>> _normalizePendingToMissed(
      List<IntakeRecord> list) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final result = <IntakeRecord>[];

    for (final r in list) {
      var rec = r;

      if (rec.status == 'pending') {
        final d = DateTime.parse(rec.scheduledAt);
        final recDate = DateTime(d.year, d.month, d.day);

        if (recDate.isBefore(today)) {
          rec = IntakeRecord(
            recordId: rec.recordId,
            medId: rec.medId,
            scheduledAt: rec.scheduledAt,
            takenAt: rec.takenAt,
            status: 'missed',
            syncStatus: 'not_synced',
          );
          await database.intakeRecordDao.updateRecord(rec);
        }
      }

      result.add(rec);
    }

    // ترتيب من الأكبر للأصغر
    result.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    return result;
  }

  void _recalculateStats() {
    if (records.isEmpty) {
      takenDoses.value = 0;
      missedDoses.value = 0;
      adherence.value = 0;
      return;
    }

    final taken = records.where((r) => r.status == 'taken').length;
    final missed = records.where((r) => r.status == 'missed').length;
    final total = records.length;

    takenDoses.value = taken;
    missedDoses.value = missed;
    adherence.value = total == 0 ? 0 : (taken / total) * 100.0;
  }

  // === Helpers للـ UI ===

  List<IntakeRecord> get filteredRecords {
    return records.where((r) {
      if (selectedMedId.value != 0 && r.medId != selectedMedId.value) {
        return false;
      }
      if (selectedStatus.value != 'all' && r.status != selectedStatus.value) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
  }

  String medicationNameFor(IntakeRecord r) {
    final med = medsById[r.medId];
    return med?.name ?? 'Unknown';
  }

  // تنسيق التاريخ+الوقت للعرض
  String formatScheduledAt(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final date =
          '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
      final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour < 12 ? 'AM' : 'PM';
      return '$date • $hour12:$minute $period';
    } catch (_) {
      return iso;
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'taken':
        return Colors.green;
      case 'missed':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String statusLabel(String status) {
    switch (status) {
      case 'taken':
        return 'Taken';
      case 'missed':
        return 'Missed';
      default:
        return 'Pending';
    }
  }

  // === تغيير الفلاتر من الـ UI ===

  void changeStatusFilter(String value) {
    selectedStatus.value = value;
  }

  void changeMedFilter(int medId) {
    selectedMedId.value = medId;
  }

  // === تحديث حالة جرعة واحدة (لو حبيت تستخدمها من شاشة تانية) ===

  Future<void> markRecordStatus(
      IntakeRecord record, String newStatus) async {
    final updated = IntakeRecord(
      recordId: record.recordId,
      medId: record.medId,
      scheduledAt: record.scheduledAt,
      takenAt: newStatus == 'taken'
          ? DateTime.now().toIso8601String()
          : record.takenAt,
      status: newStatus,
      syncStatus: 'not_synced',
    );

    await database.intakeRecordDao.updateRecord(updated);

    final index = records.indexWhere((r) => r.recordId == record.recordId);
    if (index != -1) {
      records[index] = updated;
    }
    _recalculateStats();
  }
}
