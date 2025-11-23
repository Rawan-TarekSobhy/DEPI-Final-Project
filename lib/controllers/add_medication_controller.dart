import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reminder_app/main.dart';
import 'package:reminder_app/model/medication_model.dart';
import 'package:reminder_app/services/Supabase_service.dart';

class AddMedicationController extends GetxController {
  final SupabaseService _supabaseService = Get.find();
  final ImagePicker _picker = ImagePicker();

  final name = ''.obs;
  final dosage = 0.0.obs;
  final frequency = 'Select frequency'.obs;
  final duration = 'Select duration'.obs;
  final notes = ''.obs;

  // Store selected image
  final imageFile = Rx<XFile?>(null);

  final isLoading = false.obs;
  final firstDoseTime = TimeOfDay.now().obs;
  final dailyDoseTimes = <String>[].obs;
  final startDate = DateTime.now().obs;

  final List<String> frequencyOptions = [
    'Once daily',
    'Twice daily (2x/day)',
    'Three times daily (3x/day)',
    'Four times daily (4x/day)',
    'As needed',
  ];

  final List<String> durationOptions = [
    '7 days',
    '14 days',
    '30 days',
    '90 days',
    'Ongoing',
  ];

  // Pick image from gallery
  Future<void> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      imageFile.value = image;
      Get.snackbar(
        'Success',
        'Image selected from gallery',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
      );
    } else {
      Get.snackbar(
        'Notice',
        'No image selected',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.yellow,
      );
    }
  }

  // Take image from camera
  Future<void> takeImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      imageFile.value = image;
      Get.snackbar(
        'Success',
        'Image captured from camera',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
      );
    } else {
      Get.snackbar(
        'Notice',
        'No image captured',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.yellow,
      );
    }
  }

  // Calculate daily dose times based on frequency and first dose
  void calculateDoseTimes() {
    dailyDoseTimes.clear();

    int dosesCount;
    if (frequency.value.contains('Once daily')) {
      dosesCount = 1;
    } else if (frequency.value.contains('Twice daily')) {
      dosesCount = 2;
    } else if (frequency.value.contains('Three times daily')) {
      dosesCount = 3;
    } else if (frequency.value.contains('Four times daily')) {
      dosesCount = 4;
    } else {
      dosesCount = 0;
      return;
    }

    final int intervalHours = dosesCount > 0 ? (24 ~/ dosesCount) : 0;

    final DateTime initialDateTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      firstDoseTime.value.hour,
      firstDoseTime.value.minute,
    );

    for (int i = 0; i < dosesCount; i++) {
      final DateTime doseTime =
          initialDateTime.add(Duration(hours: i * intervalHours));
      final String formattedTime =
          _formatTimeOfDay(TimeOfDay.fromDateTime(doseTime));
      dailyDoseTimes.add(formattedTime);
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  // Calculate end date based on duration
  DateTime? calculateEndDate() {
    final durationText = duration.value.toLowerCase();
    final start = startDate.value;

    if (durationText.contains('ongoing')) {
      return null;
    }

    int days = 0;
    if (durationText.contains('7 days')) {
      days = 7;
    } else if (durationText.contains('14 days')) {
      days = 14;
    } else if (durationText.contains('30 days')) {
      days = 30;
    } else if (durationText.contains('90 days')) {
      days = 90;
    }

    return days > 0 ? start.add(Duration(days: days - 1)) : null;
  }

  Future<void> saveMedication() async {
    if (name.value.isEmpty ||
        dosage.value <= 0 ||
        frequency.value == 'Select frequency' ||
        duration.value == 'Select duration') {
      Get.snackbar(
        'Invalid input',
        'Please fill all required fields.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
      return;
    }

    isLoading.value = true;
    String? imageUrl;

    try {
      // Upload image if selected
      if (imageFile.value != null) {
        imageUrl = await _supabaseService.uploadImage(imageFile.value!);
      }

      final calculatedEndDate = calculateEndDate();

      final newMedication = Medications(
        name: name.value,
        dosage: dosage.value,
        frequency: frequency.value,
        startDate: startDate.value,
        durationOfUse: duration.value,
        notes: notes.value.isNotEmpty ? notes.value : null,
        imageUrl: imageUrl,
        endDate: calculatedEndDate,
        userId: cloud.auth.currentUser?.id,
      );

      await _supabaseService.addMedication(newMedication);

      Get.back();
      Get.snackbar(
        'Success',
        'Medication added successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred while saving.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
