// lib/controllers/navigation_controller.dart

import 'package:get/get.dart';
import 'package:reminder_app/controllers/home_controller.dart';
import 'package:reminder_app/controllers/medication_log_controller.dart';
import 'package:reminder_app/controllers/medications_controller.dart';

class NavigationController extends GetxController {
  // Current selected index (4 tabs only)
  final RxInt selectedIndex = 0.obs;

  // List of navigation destinations (4 routes)
  final List<String> routes = [
    '/home',
    '/medications',
    '/medication-log',
    '/profile',
  ];

  // Navigate to specific index
  void navigateToIndex(int index) {
    selectedIndex.value = index;
    if(index ==2){
    final c = Get.find<MedicationLogController>();
    c.loadLog();
    }
    if(index ==0){
    final c = Get.find<HomeController>();
    c.loadTodayDoses();
    }
    if(index ==1){
    final c = Get.find<MedicationsController>();
    c.loadMedications();
    }
  }

  // Navigate to specific route
  void navigateToRoute(String route) {
    final index = routes.indexOf(route);
    if (index != -1) {
      selectedIndex.value = index;
    }
  }

  // Get current route
  String get currentRoute => routes[selectedIndex.value];
  
  // Get current tab name
  String get currentTabName {
    switch (selectedIndex.value) {
      case 0:
        return 'Home';
      case 1:
        return 'Medications';
      case 2:
        return 'Log';
      case 3:
        return 'Profile';
      default:
        return 'Home';
    }
  }
}
