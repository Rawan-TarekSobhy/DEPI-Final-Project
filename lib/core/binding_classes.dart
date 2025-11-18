import 'package:get/get.dart';
import 'package:reminder_app/services/connectivity_service.dart';

import 'package:reminder_app/controllers/home_controller.dart';
import 'package:reminder_app/controllers/login_controller.dart';
import 'package:reminder_app/controllers/nearby_pharmacies_controller.dart';
import 'package:reminder_app/services/pharmacies_service.dart';
import 'package:reminder_app/controllers/registration_controller.dart';


class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
  }
}


class SignUpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignUpController>(() => SignUpController());
  }
}

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}


class NearbyPharmaciesBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ConnectivityService>()) {
      Get.lazyPut<ConnectivityService>(() => ConnectivityService());
    }

    if (!Get.isRegistered<PharmaciesService>()) {
      Get.lazyPut<PharmaciesService>(() => PharmaciesService());
    }

    if (!Get.isRegistered<NearbyPharmaciesController>()) {
      Get.lazyPut<NearbyPharmaciesController>(
        () => NearbyPharmaciesController(),
      );
    }
  }
}
