import 'package:floor/floor.dart';
import 'package:reminder_app/data/entity/medications.dart';

@dao
abstract class MedicationsDao {
  @Query('SELECT * FROM medications WHERE userId = :userId')
  Future<List<Medication>> getMedicationsByUser(String userId);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertMedication(Medication medication);
  
  @update
  Future<void> updateMedication(Medication med);  

  @delete
  Future<void> deleteMedication(Medication med);    
}

