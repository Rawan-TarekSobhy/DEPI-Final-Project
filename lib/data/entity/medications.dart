
import 'package:floor/floor.dart';
import 'package:reminder_app/data/entity/users.dart';

/// MEDICATIONS TABLE
@Entity(
  tableName: 'medications',
  foreignKeys: [
    ForeignKey(
      childColumns: ['userId'],
      parentColumns: ['userId'],
      entity: User,
      onDelete: ForeignKeyAction.cascade,
      onUpdate: ForeignKeyAction.cascade,
    ),
  ],
)
class Medication {
  @PrimaryKey(autoGenerate: true)
  final int? medId;
  final int userId;
  final String name;
  final String? dosage;
  final String? frequency;
  final String? durationOfUse;
  final String? notes;
  final String? imageUrl;

  Medication({
    this.medId,
    required this.userId,
    required this.name,
    this.dosage,
    this.frequency,
    this.durationOfUse,
    this.notes,
    this.imageUrl,
  });
}
