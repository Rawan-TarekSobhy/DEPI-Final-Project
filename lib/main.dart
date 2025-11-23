import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reminder_app/data/app_database.dart';
import 'package:reminder_app/services/Supabase_service.dart';
import 'package:reminder_app/services/auth_service.dart';
import 'package:reminder_app/core/binding_classes.dart';
import 'package:reminder_app/services/connectivity_service.dart';
import 'package:reminder_app/views/add_medication_page.dart';
import 'package:reminder_app/views/home_page.dart';
import 'package:reminder_app/views/login_page.dart';
import 'package:reminder_app/views/medication_log_page.dart';
import 'package:reminder_app/views/nearby_pharmacies_page.dart';
import 'package:reminder_app/services/pharmacies_service.dart';
import 'package:reminder_app/views/registration_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDatabase();
  await Supabase.initialize(
    url: 'https://rauyhbcxlbpsxlemntsz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJhdXloYmN4bGJwc3hsZW1udHN6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1MjI1NjUsImV4cCI6MjA3ODA5ODU2NX0.LpMWrdD4z9VH7nyffp8stJp3U4CEUt0-1uOmMx8nfG8',
  );

  runApp(const MyApp());
}

final cloud = Supabase.instance.client;

Future<void> initDatabase() async {
  await copyDatabase();

  //get database object
  //connect to database
  final dir = await getApplicationDocumentsDirectory();
  final dbPath = join(dir.path, 'medication_data.db');

  database = await $FloorAppDatabase.databaseBuilder(dbPath).build();
}

late final AppDatabase database;

Future<void> copyDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  final path = join(dir.path, 'medication_data.db'); // c://app1/movies.db.db
  // print(dir);

  if (File(path).existsSync()) return;

  //copy from assets to this path
  ByteData data = await rootBundle.load('assets/database/medication_data.db');
  List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  await File(path).writeAsBytes(bytes);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/addMedication',
      initialBinding: BindingsBuilder(() {
        Get.lazyPut(() => AuthService(), fenix: true);
        Get.lazyPut(() => ConnectivityService(), fenix: true);
        Get.lazyPut(() => PharmaciesService());
        Get.lazyPut(()=> SupabaseService());
      }),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'YourFontFamily',
      ),
      getPages: [
        GetPage(name: '/home', page: () => HomePage(), binding: HomeBinding()),
        GetPage(
          name: '/login',
          page: () => LoginPage(),
          binding: LoginBinding(),
        ),
        GetPage(
          name: '/register',
          page: () => SignUpView(),
          binding: SignUpBinding(),
        ),
        GetPage(
          name: '/nerbyPharmacies',
          page: () => NearbyPharmaciesPage(),
          binding: NearbyPharmaciesBinding(),
        ),
        GetPage(
          name: '/medicationLog',
          page: () => MedicationLogPage(),
          binding: MedicationLogBinding(),
        ),
        GetPage(
          name: '/addMedication',
          page: () => AddMedicationPage(),
          binding: AddMedicationBinding(),
        ),
      ],
    );
  }
}
