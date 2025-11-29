// records_service.dart
import 'package:get/get.dart';
import 'package:reminder_app/main.dart';
import 'package:reminder_app/data/entity/intake_records.dart';

class RecordsService extends GetxService {
  Future<void> addRecordsToSupabase(List<IntakeRecord> records) async {
    if (records.isEmpty) return;
    final payload = records.map((r) {
      return {
        'med_id': r.medId,
        'scheduled_at': r.scheduledAt,
        'taken_at': r.takenAt,
        'status': r.status,
      };
    }).toList();

    await cloud.from('intake_records').insert(payload);
  }

  Future<void> updateRecordStatusOnSupabase(IntakeRecord record) async {
    await cloud
        .from('intake_records')
        .update({
          'taken_at': record.takenAt,
          'status': record.status,
        })
        .eq('record_id', record.recordId.toString());
  }

  Future<void> deleteRecordsForMedFromSupabase(int medId) async {
    await cloud.from('intake_records').delete().eq('med_id', medId);
  }
}
