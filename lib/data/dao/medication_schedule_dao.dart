import 'package:floor/floor.dart';
import 'package:reminder_app/data/entity/medication_schedule.dart';

@dao
abstract class MedicationScheduleDao {
  @Query('SELECT * FROM medication_schedule WHERE medId = :medId')
  Future<List<MedicationSchedule>> getSchedulesByMedId(int medId);

  @insert
  Future<void> insertSchedule(MedicationSchedule schedule);

  @Query('DELETE FROM medication_schedule WHERE medId = :medId')
  Future<void> deleteSchedulesByMedId(int medId);
}
