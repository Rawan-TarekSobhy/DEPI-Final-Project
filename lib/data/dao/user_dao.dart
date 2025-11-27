import 'package:floor/floor.dart';
import 'package:reminder_app/data/entity/users.dart';

@dao
abstract class UserDao {
  @Query('SELECT * FROM users WHERE userId = :userId')
  Future<User?> getUserById(String userId);

  @insert
  Future<void> insertUser(User user);

  @update
  Future<void> updateUser(User user);

  @Query('SELECT * FROM users')
  Future<List<User>> getAllUsers();

  @Query('DELETE FROM users')
  Future<void> deleteAllUsers();
}
