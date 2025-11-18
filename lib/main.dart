import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reminder_app/services/auth_service.dart';
import 'package:reminder_app/core/binding_classes.dart';
import 'package:reminder_app/services/connectivity_service.dart';
import 'package:reminder_app/presentation/home_page.dart';
import 'package:reminder_app/presentation/login_page.dart';
import 'package:reminder_app/presentation/nearby_pharmacies_page.dart';
import 'package:reminder_app/services/pharmacies_service.dart';
import 'package:reminder_app/presentation/registration_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rauyhbcxlbpsxlemntsz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJhdXloYmN4bGJwc3hsZW1udHN6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1MjI1NjUsImV4cCI6MjA3ODA5ODU2NX0.LpMWrdD4z9VH7nyffp8stJp3U4CEUt0-1uOmMx8nfG8',
  );

  runApp(const MyApp());
}

final cloud = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      initialBinding: BindingsBuilder(() {
        Get.lazyPut(() => AuthService(), fenix: true);
        Get.lazyPut(() => ConnectivityService());
        Get.lazyPut(() => PharmaciesService());
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
      ],
    );
  }
}
