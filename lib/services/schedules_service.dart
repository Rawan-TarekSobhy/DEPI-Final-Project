// schedules_service.dart
import 'package:get/get.dart';
import 'package:reminder_app/main.dart';
import 'package:reminder_app/data/entity/medication_schedule.dart';

class SchedulesService extends GetxService {
  Future<void> addScheduleToSupabase(MedicationSchedule schedule) async {
    await cloud.from('medication_schedules').insert({
      'med_id': schedule.medId,
      'intake_time': schedule.intakeTime,
    });
  }

  Future<void> deleteSchedulesForMedFromSupabase(int medId) async {
    await cloud.from('medication_schedules').delete().eq('med_id', medId);
  }

  // لو عايز Update برضه تضيفه بنفس الشكل
}
