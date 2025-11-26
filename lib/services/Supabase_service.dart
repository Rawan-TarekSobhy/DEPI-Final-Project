// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:reminder_app/main.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// // import '../model/medication_model.dart';

// class SupabaseService extends GetxService {
//   static const String _medicationBucket = 'medication_image'; // تأكد من اسم سلة التخزين الصحيح في Supabase
//   // static const String _medicationsTable = 'medications';

//   // 1. استقبال XFile
//   Future<String?> uploadImage(XFile imageFile) async {
//     try {
//       // 2. قراءة بايتات الملف
//       final bytes = await imageFile.readAsBytes();

//       // توليد اسم ملف فريد
//       final fileName = 'medication_images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';

//       // 3. رفع البيانات الثنائية (Bytes) إلى Supabase
//       await cloud.storage.from(_medicationBucket).uploadBinary(fileName, bytes,
//           fileOptions: const FileOptions(
//             contentType: 'image/jpeg',
//             cacheControl: '3600',
//           ));

//       final publicUrl = cloud.storage.from(_medicationBucket).getPublicUrl(fileName);
//       return publicUrl;
//     } catch (e) {
//       Get.snackbar('خطأ في التحميل', 'فشل تحميل الصورة: $e', snackPosition: SnackPosition.BOTTOM);
//       return null;
//     }
//   }

// //   Future<void> addMedication(Medications medication) async {
// //     try {
// //       await cloud.from(_medicationsTable).insert(medication.toJson()).select();

// //     } on PostgrestException catch (e) {
// //       Get.snackbar('خطأ في قاعدة البيانات', 'فشل إضافة الدواء: ${e.message}',
// //           snackPosition: SnackPosition.BOTTOM);
// //       throw e;
// //     } catch (e) {
// //       Get.snackbar('خطأ', 'حدث خطأ غير متوقع أثناء إضافة الدواء.',
// //           snackPosition: SnackPosition.BOTTOM);
// //       throw e;
// //     }
// //   }
  
  

// }