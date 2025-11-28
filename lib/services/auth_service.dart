// import 'package:reminder_app/core/core_exception.dart';
// import 'package:reminder_app/core/init_local_db.dart';
// import 'package:reminder_app/data/entity/users.dart';
// import 'package:reminder_app/main.dart';
// import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;

// class AuthService {
//   supabase_flutter.User? get currentUser => cloud.auth.currentUser;
//   String? get currentUserId => cloud.auth.currentUser?.id;

//   Future<void> login(String email, String password) async {
//     try {
//       await cloud.auth.signInWithPassword(password: password, email: email);

//       final supabaseUser = cloud.auth.currentUser;
//       if (supabaseUser != null) {
//         await saveUserToLocal(supabaseUser, email);
//       }
//     } on supabase_flutter.AuthException catch (e) {
//       if (e.message.toLowerCase().contains('invalid login credentials')) {
//         throw InvalidCredentialsException();
//       } else {
//         throw Exception('Authentication error: ${e.message}');
//       }
//     } catch (e) {
//       throw Exception('Unexpected error occurred: $e');
//     }
//   }

//   Future<void> register(String email, String password, String fullName) async {
//     try {
//       final response = await cloud.auth.signUp(
//         password: password,
//         email: email,
//       );

//       final user = response.user;
//       if (user == null) {
//         throw Exception('Failed to create user');
//       }

//       await cloud.from('users').insert({
//         'user_id': user.id,
//         'name': fullName,
//         'sync_status': 'synced',
//       });

//       await saveUserToLocal(user, email, fullName);

//       return;
//     } on supabase_flutter.AuthException catch (e) {
//       final msg = e.message.toLowerCase();
//       if (msg.contains('user already registered') ||
//           msg.contains('email already registered')) {
//         throw EmailAlreadyExistsException();
//       } else {
//         throw Exception('Registration auth error: ${e.message}');
//       }
//     } on supabase_flutter.PostgrestException catch (e) {
//       throw Exception('Database error: ${e.message}');
//     } catch (e) {
//       throw Exception('Unexpected registration error: $e');
//     }
//   }

//   Future<void> saveUserToLocal(
//     supabase_flutter.User supabaseUser,
//     String email, [
//     String? name,
//   ]) async {
//     try {
//       final existingUser = await database.userDao.getUserById(supabaseUser.id);

//       if (existingUser == null) {
//         final localUser = User(
//           userId: supabaseUser.id,
//           name: name ?? supabaseUser.userMetadata?['name'] ?? '',
//           email: email,
//           password: '', 
//           syncStatus: 'synced',
//         );

//         await database.userDao.insertUser(localUser);
//         // await database.userDao.deleteAllUsers();
//         // final d = await database.userDao.getAllUsers();
//         // print(d);
//       }
//     } catch (e) {
//       print('Error saving user to local database: $e');
//     }
//   }
// }

import 'package:reminder_app/core/core_exception.dart';
import 'package:reminder_app/core/init_local_db.dart';
import 'package:reminder_app/data/entity/users.dart';
import 'package:reminder_app/data/entity/medications.dart';
import 'package:reminder_app/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;

class AuthService {
  supabase_flutter.User? get currentUser => cloud.auth.currentUser;
  String? get currentUserId => cloud.auth.currentUser?.id;
  Future<void> logout() async {
  try {
    await cloud.auth.signOut();
  } catch (e) {
    print('Error during logout: $e');
  }
}


  Future<void> login(String email, String password) async {
    try {
      await cloud.auth.signInWithPassword(password: password, email: email);
      final supabaseUser = cloud.auth.currentUser;
      
      if (supabaseUser != null) {
        await saveUserToLocal(supabaseUser, email);
        
        // Sync data from Supabase after successful login
        await syncDataFromSupabase(supabaseUser.id);
      }
    } on supabase_flutter.AuthException catch (e) {
      if (e.message.toLowerCase().contains('invalid login credentials')) {
        throw InvalidCredentialsException();
      } else {
        throw Exception('Authentication error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error occurred: $e');
    }
  }

  Future<void> register(String email, String password, String fullName) async {
    try {
      await cloud.auth.signUp(password: password, email: email);
      final supabaseUser = cloud.auth.currentUser;

      if (supabaseUser != null) {
        await cloud.from('users').insert({
          'user_id': supabaseUser.id,
          'name': fullName,
          'sync_status': 'synced',
        });
        await saveUserToLocal(supabaseUser, email, fullName);
      }
    } on supabase_flutter.AuthException catch (e) {
      if (e.message.toLowerCase().contains('user already registered') ||
          e.message.toLowerCase().contains('email already registered')) {
        throw EmailAlreadyExistsException();
      } else {
        throw Exception('Authentication error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error occurred: $e');
    }
  }

  Future<void> saveUserToLocal(
    supabase_flutter.User supabaseUser,
    String email, [
    String? name,
  ]) async {
    final existingUser = await database.userDao.getUserById(supabaseUser.id);

    if (existingUser == null) {
      final user = User(
        userId: supabaseUser.id,
        name: name ?? supabaseUser.userMetadata?['name'] ?? 'User',
        email: email,
        password: '',
        syncStatus: 'synced',
      );
      await database.userDao.insertUser(user);
    }
  }

  // New Method: Sync medications from Supabase to Local
  Future<void> syncDataFromSupabase(String userId) async {
    try {
      // 1. Check if local medications are empty
      final localMedications = await database.medicationsDao.getMedicationsByUser(userId);
      
      if (localMedications.isEmpty) {
        print('Local database is empty. Fetching from Supabase...');
        
        // 2. Fetch medications from Supabase
        final response = await cloud
            .from('medications')
            .select('*')
            .eq('user_id', userId);
        
        if (response != null && response.isNotEmpty) {
          print('Found ${response.length} medications in Supabase');
          
          // 3. Insert each medication into local database
          for (var medData in response) {
            final medication = Medication(
              medId: null, // Auto-generate local ID
              userId: userId,
              name: medData['name'] ?? '',
              dosage: medData['dosage'],
              frequency: medData['frequency'],
              durationOfUse: medData['duration_of_use'],
              notes: medData['notes'],
              imageUrl: medData['image_url'],
              syncStatus: 'synced',
            );
            
            await database.medicationsDao.insertMedication(medication);
          }
          
          print('Successfully synced ${response.length} medications to local database');
        } else {
          print('No medications found in Supabase for this user');
        }
      } else {
        print('ℹLocal database already has ${localMedications.length} medications. Skipping sync.');
      }
    } catch (e) {
      print('Error syncing data from Supabase: $e');
      // Don't throw - login should succeed even if sync fails
    }
  }
}
