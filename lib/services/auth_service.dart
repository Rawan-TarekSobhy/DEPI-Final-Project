import 'package:reminder_app/core/core_exception.dart';
import 'package:reminder_app/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  Future login(String email, String password) async {
    try {
      await cloud.auth.signInWithPassword(
        password: password,
        email: email,
      );
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('invalid login credentials')) {
        throw InvalidCredentialsException();
      } else {
        throw Exception('Authentication error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error occurred: $e');
    }
  }

  Future register(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      // 1) إنشاء المستخدم في Auth
      final response = await cloud.auth.signUp(
        password: password,
        email: email,
      );

      final user = response.user;

      if (user == null) {
        throw Exception('Failed to create user');
      }

      // 2) إدخال بيانات إضافية في جدول users
      await cloud.from('users').insert({
        'user_id': user.id,
        'name': fullName,
      });

      return;
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('user already registered') ||
          msg.contains('email already registered')) {
        throw EmailAlreadyExistsException();
      } else {
        throw Exception('Registration auth error: ${e.message}');
      }
    } on PostgrestException catch (e) {
      // لو حصل خطأ في جدول users
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected registration error: $e');
    }
  }
}
