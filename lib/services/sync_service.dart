// import 'package:get/get.dart';
// import 'package:reminder_app/core/init_local_db.dart';
// import 'package:reminder_app/services/medications_service.dart';
// import 'package:reminder_app/services/schedules_service.dart';
// import 'package:reminder_app/services/records_service.dart';

// class SyncService extends GetxService {
//   final MedicationsService medsService = Get.find();
//   final SchedulesService schedulesService = Get.find();
//   final RecordsService recordsService = Get.find();

//   Future<void> syncAll(String userId) async {
//     // 1) Sync medications not_synced
//     final unsyncedMeds =
//         await database.medicationsDao.getMedicationsByUserWithStatus(userId, 'not_synced');
//     for (final med in unsyncedMeds) {
//       await medsService.addMedicationToSupabase(med, userId);
//       await database.medicationsDao.updateSyncStatus(med.medId!, 'synced');
//     }

//     // 2) Sync schedules
//     final unsyncedSchedules =
//         await database.medicationScheduleDao.getSchedulesBySyncStatus('not_synced');
//     for (final s in unsyncedSchedules) {
//       await schedulesService.addScheduleToSupabase(s);
//       await database.medicationScheduleDao.updateSyncStatus(s.scheduleId!, 'synced');
//     }

//     // 3) Sync intake_records
//     final unsyncedRecords =
//         await database.intakeRecordDao.getRecordsBySyncStatus('not_synced');
//     await recordsService.addRecordsToSupabase(unsyncedRecords);
//     for (final r in unsyncedRecords) {
//       await database.intakeRecordDao.updateSyncStatus(r.recordId!, 'synced');
//     }
//   }
// }
