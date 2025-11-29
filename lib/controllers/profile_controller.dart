import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reminder_app/core/init_local_db.dart';
import 'package:reminder_app/data/entity/users.dart';
import 'package:reminder_app/services/auth_service.dart';

class ProfileController extends GetxController {
  final AuthService authService = Get.find();
  final isLoading = false.obs;
  final user = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  Future<void> loadUser() async {
    final id = authService.currentUserId;
    if (id == null || id.isEmpty) return;

    isLoading.value = true;
    try {
      final u = await database.userDao.getUserById(id);
      user.value = u;
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ FIXED: Complete saveUser method with proper update
  Future<void> saveUser(User updated) async {
    try {
      isLoading.value = true;
      
      // Use updateUser instead of deleteAll + insert
      await database.userDao.updateUser(updated);
      
      // Update the reactive user value
      user.value = updated;
      
      // Show success message
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4FC3F7),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      print('Error updating user: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
