import 'package:get/get.dart';
import 'package:reminder_app/main.dart'; // عشان cloud
import 'package:reminder_app/data/entity/medications.dart';

class MedicationsService extends GetxService {
  // ADD to Supabase
  Future<String?> addMedicationToSupabase(Medication med, String userId) async {
    final data = {
      'user_id': userId,
      'name': med.name,
      'dosage': med.dosage,
      'frequency': med.frequency,
      'duration_of_use': med.durationOfUse,
      'notes': med.notes,
      'image_url': med.imageUrl,
    };

    final response = await cloud.from('medications').insert(data).select('id').maybeSingle();
    // رجّع الـ remote id لو محتاجه
    return response != null ? response['id']?.toString() : null;
  }

  // UPDATE
  Future<void> updateMedicationOnSupabase(Medication med, String remoteId) async {
    await cloud
        .from('medications')
        .update({
          'name': med.name,
          'dosage': med.dosage,
          'frequency': med.frequency,
          'duration_of_use': med.durationOfUse,
          'notes': med.notes,
          'image_url': med.imageUrl,
        })
        .eq('id', remoteId);
  }

  // DELETE
  Future<void> deleteMedicationFromSupabase(String remoteId) async {
    await cloud.from('medications').delete().eq('id', remoteId);
  }
}
