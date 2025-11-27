import 'dart:async';
import 'dart:io';
import 'package:file_saver/file_saver.dart'; // تأكد أن الإصدار في pubspec هو 0.2.x أو أحدث
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:reminder_app/model/document_model.dart';
import 'package:reminder_app/services/Supabase_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:reminder_app/services/connectivity_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:reminder_app/services/auth_service.dart';


class UploadDocumentsController extends GetxController {

  final SupabaseService supa = Get.find<SupabaseService>();
  final ConnectivityService connectivityService = Get.find<ConnectivityService>();
  late final AuthService authService = Get.find<AuthService>();

  final document = <Documents>[].obs;
  final isLoading = false.obs;
  final selectedFile = Rx<XFile?>(null);

  // متغير لتخزين مسار آخر ملف تم تحميله (اختياري)
  String? lastSavedPath;

  late StreamSubscription<dynamic> _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    fetechDOCS();

    // مراقبة الاتصال للمزامنة التلقائية
    _connectivitySubscription = connectivityService.checkforInternet().listen((results) {
      if (results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi)) {
        _syncPendingUploads();
      }
    });
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }

  // ----------------------------------------------------
  // 1. FETCH LOGIC (جلب البيانات)
  // ----------------------------------------------------

  Future<void> fetechDOCS() async {
    try {
      isLoading.value = true;
      final rawData = await supa.getDocuments();
      final List<Documents> fetchedDocuments = rawData.map((json) {
        if (json.containsKey('file_url')) {
          return Documents.fromJson(json);
        }
        throw Exception("Invalid data structure received.");
      }).toList();

      document.assignAll(fetchedDocuments);

    } catch (e) {
      print("Error fetching documents: $e");
      Get.snackbar(
        'Fetch Error',
        'Failed to load documents. Showing local data if available.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ----------------------------------------------------
  // 2. UPLOAD LOGIC (Offline-First)
  // ----------------------------------------------------

  Future<void> pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['pdf'], type: FileType.custom);

    if (result != null) {
      final PlatformFile file = result.files.single;
      final String? filePath = file.path;
      final String? filename = file.name;

      if (filename != null && filePath != null) {
        selectedFile.value = XFile(filePath);
        Get.snackbar('File Selected', 'PDF file selected successfully.',
            backgroundColor: Colors.blue);
      } else {
        selectedFile.value = null;
      }
    }
  }

  Future<void> uploadDocument() async {
    if (selectedFile.value == null) {
      Get.snackbar('Alert', 'Please select a file first.',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    final fileToUpload = selectedFile.value!;
    isLoading.value = true;

    final isConnected = await connectivityService.connected();

    // تجهيز المستند (مبدئياً أوفلاين)
    final newDocument = Documents(
      userId: authService.currentUserId,
      file_name: fileToUpload.name,
      file_Url: '',
      local_direct: fileToUpload.path,
      is_synced: isConnected,
      created_at: DateTime.now(),
    );

    if (isConnected) {
      // 🟢 متصل: ارفع للسيرفر
      try {
        final publicUrl = await supa.uploadDocument(fileToUpload);

        if (publicUrl != null) {
          final syncedDoc = newDocument.copyWith(
            file_Url: publicUrl,
            is_synced: true,
          );

          await supa.saveDocumentMetadata(syncedDoc);
          document.insert(0, syncedDoc);

          Get.snackbar('Success', 'Document uploaded successfully!',
              backgroundColor: Colors.green, colorText: Colors.white);

        } else {
          throw Exception('Failed to get public URL.');
        }

      } catch (e) {
        print('Upload Failed: $e');
        Get.snackbar('Error', 'Upload failed. Saving offline.',
            backgroundColor: Colors.red, colorText: Colors.white);
        // فشل الرفع -> احفظ أوفلاين
        document.insert(0, newDocument.copyWith(is_synced: false));
      }
    } else {
      // 🔴 غير متصل: احفظ أوفلاين فوراً
      document.insert(0, newDocument.copyWith(is_synced: false));

      Get.snackbar('Offline Saved', 'No internet. File saved locally and will sync later.',
          backgroundColor: Colors.orange, colorText: Colors.white);
    }

    selectedFile.value = null;
    isLoading.value = false;
    Get.back(); // إغلاق المودال
  }

  // منطق المزامنة التلقائية
  Future<void> _syncPendingUploads() async {
    final unsyncedDocs = document.where((doc) => doc.is_synced == false).toList();
    if (unsyncedDocs.isEmpty) return;

    Get.snackbar('Syncing', 'Uploading ${unsyncedDocs.length} pending files...',
        backgroundColor: Colors.lightBlue, duration: const Duration(seconds: 3));

    for (var doc in unsyncedDocs) {
      if (doc.local_direct == null) continue;

      try {
        final fileToUpload = XFile(doc.local_direct!);
        final publicUrl = await supa.uploadDocument(fileToUpload);

        if (publicUrl != null) {
          final syncedDoc = doc.copyWith(
            file_Url: publicUrl,
            is_synced: true,
          );

          await supa.saveDocumentMetadata(syncedDoc);

          final index = document.indexOf(doc);
          if (index != -1) {
            document[index] = syncedDoc;
            document.refresh();
          }
        }
      } catch (e) {
        print('Sync Error: $e');
      }
    }
  }

  // ----------------------------------------------------
  // 3. DOWNLOAD & VIEW LOGIC (بدون Permission Handler)
  // ----------------------------------------------------

  // دالة التحميل (تستخدم saveAs للأندرويد للحفظ خارج الكاش)
  Future<void> downloadDocument(String fileUrl, String fileName) async {

    Get.snackbar(
        'Downloading',
        'Getting $fileName...',
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2)
    );

    try {
      // 1. تنزيل البيانات من Supabase
      final fileBytes = await supa.DownloadedDocUrl(fileUrl);

      if (fileBytes == null || fileBytes.isEmpty) {
        throw Exception('File is empty.');
      }

      String? path;

      // 2. الحفظ حسب المنصة
      if (Platform.isAndroid) {
        // ✅ saveAs: تفتح نافذة النظام للحفظ (تضمن الحفظ في Downloads أو المكان الذي يختاره المستخدم)
        // هذا يتجاوز مشكلة الكاش والأذونات المعقدة
        path = await FileSaver.instance.saveAs(
            name: fileName.split('.').first,
            bytes: fileBytes,
            fileExtension: 'pdf',
            mimeType: MimeType.pdf
        );
      } else {
        // ✅ saveFile: للـ iOS وغيره (يحفظ في Downloads عادة)
        path = await FileSaver.instance.saveFile(
            name: fileName.split('.').first,
            bytes: fileBytes,
            fileExtension: 'pdf',
            mimeType: MimeType.pdf
        );
      }

      // تحديث المسار (اختياري)
      if (path != null) {
        lastSavedPath = path;
        print("File Saved at: $path");
        Get.snackbar(
            'Success',
            'File saved successfully!',
            backgroundColor: Colors.green
        );
      }

    } catch (e) {
      print('Download Error: $e');
      Get.snackbar('Error', 'Download failed: $e', backgroundColor: Colors.red);
    }
  }

  Future<void> viewDocument(String fileUrl, String? localDirect) async {
    // محاولة فتح الملف المحلي أولاً
    if (localDirect != null) {
      final File localFile = File(localDirect);
      if (await localFile.exists()) {
        final result = await OpenFilex.open(localDirect);
        if (result.type == ResultType.done) {
          return; // تم الفتح بنجاح
        }
      }
    }

    // الفشل المحلي -> فتح الرابط أونلاين
    if (fileUrl.isNotEmpty) {
      final Uri uri = Uri.parse(fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } else {
        Get.snackbar('Error', 'Could not launch URL.', backgroundColor: Colors.red);
      }
    } else {
      Get.snackbar('Error', 'File not found locally or online.', backgroundColor: Colors.red);
    }
  }

  // 4. حذف المستند
  Future<void> deleteDocument(String? docId, bool isSynced) async {
    if (docId == null && !isSynced) {
      document.removeWhere((doc) => doc.is_synced == false);
      return;
    }
    if (docId == null) return;

    try {
      isLoading.value = true;
      final docToDelete = document.firstWhereOrNull((doc) => doc.docId == docId);

      if (docToDelete != null) {
        if(docToDelete.is_synced && docToDelete.file_Url.isNotEmpty) {
          await supa.deleteFileFromStorage(docToDelete.file_Url);
          await supa.deleteDocumentMetadata(docId);
        }

        if (docToDelete.local_direct != null) {
          final file = File(docToDelete.local_direct!);
          if (await file.exists()) await file.delete();
        }

        document.removeWhere((doc) => doc.docId == docId);
        Get.snackbar('Success', 'Deleted successfully.', backgroundColor: Colors.green);
      }
    } catch (e) {
      Get.snackbar('Error', 'Delete failed.', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  String formatDateTimeManual(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    final datePart = dateTime.toIso8601String().split('T')[0];
    return datePart;
  }
}