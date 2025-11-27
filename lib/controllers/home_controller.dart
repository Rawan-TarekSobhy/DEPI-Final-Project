import 'dart:async';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  var currentTime = "".obs;
  var currentDate = "".obs;
  var currentIndex = 0.obs;

  Timer? timer;

  // Medication states
  var aspirinTaken = false.obs;
  var aspirinPending = true.obs;

  @override
  void onInit() {
    super.onInit();
    _updateTime();

    timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _updateTime();
    });
  }

  void _updateTime() {
    DateTime now = DateTime.now();
    currentTime.value = DateFormat('hh:mm a').format(now);
    currentDate.value = DateFormat('EEEE, MMMM d').format(now);
  }

  void markAspirinAsTaken() {
    aspirinTaken.value = true;
    aspirinPending.value = false;
  }

  // Optional: reset
  void resetAspirinStatus() {
    aspirinTaken.value = false;
    aspirinPending.value = true;
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }
}
