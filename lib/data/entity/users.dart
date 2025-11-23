
import 'package:floor/floor.dart';

/// USERS TABLE
@Entity(tableName: 'users')
class User {
  @PrimaryKey(autoGenerate: true)
  final int? userId;

  final String name;
  final String email;
  final String password;
  final String? gender;
  final String? age;
  final String? bloodType;
  final String? weight;
  final String? height;

  User({
    this.userId,
    required this.name,
    required this.email,
    required this.password,
    this.gender,
    this.age,
    this.bloodType,
    this.weight,
    this.height,
  });
}
