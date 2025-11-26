import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reminder_app/controllers/home_controller.dart';

class HomePage extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: Color(0xfff5f7fb),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: controller.currentIndex.value,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xff3466f2),
        unselectedItemColor: Colors.grey,
        onTap: controller.changeTab,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.medical_services_rounded),
              label: "Medications"),
          BottomNavigationBarItem(
              icon: Icon(Icons.library_books_outlined), label: "Log"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      )),
      body: SafeArea(
        child: Column(
          children: [
            // ===== HEADER =====
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, 28, 20, 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff4fa4f3), Color(0xff68c4f8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 30,
                          height: 30,
                          fit: BoxFit.contain,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MediTrack',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Your Health, Your Schedule',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        'Good Morning',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.nightlight_outlined,
                          color: Colors.white70, size: 26),
                      SizedBox(width: 10),
                    //  Icon(Icons.notifications_none,
                    //      color: Colors.white70, size: 24),
                    ],
                  ),
                  SizedBox(height: 4),
                  Obx(() => Text(
                    controller.currentDate.value,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  )),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Time',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                            ),
                            Obx(() => Text(
                              controller.currentTime.value,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            )),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.all(12),
                          child: Icon(Icons.access_time,
                              color: Colors.white, size: 30),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                color: Colors.white,
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _quickActionButton(
                            Icons.add,
                            'Add Med',
                                () => Get.toNamed('/addMedication'),
                          ),
                          _quickActionButton(
                            Icons.list_alt_outlined,
                            'View Log',
                                () => controller.changeTab(2),
                          ),
                          _quickActionButton(
                            Icons.location_on_outlined,
                            'Pharmacies',
                                () => Get.toNamed('/nearbyPharmacies'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 30),

            // ===== Today's Schedule Header =====
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    "Today's Schedule",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed('/medicationLog');
                    },
                    child: Text(
                      "View All",
                      style: TextStyle(fontSize: 14, color: Color(0xff070707)),
                    ),
                  )
                ],
              ),
            ),

            SizedBox(height: 12),

            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _medScheduleCard(
                    name: "Aspirin",
                    dose: "100mg · Twice daily",
                    time: "9:00 AM",
                    taken: controller.aspirinTaken,
                    pending: controller.aspirinPending,
                    onTap: controller.markAspirinAsTaken,
                  ),
                  _medScheduleCard(
                    name: "Lisinopril",
                    dose: "10mg · Once daily",
                    time: "10:00 AM",
                    taken: true.obs,
                    pending: false.obs,
                    onTap: null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Color(0xff3466f2), size: 30),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Color(0xff3466f2),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _medScheduleCard({
    required String name,
    required String dose,
    required String time,
    required RxBool taken,
    required RxBool pending,
    VoidCallback? onTap,
  }) {
    return Obx(() => Container(
      margin: EdgeInsets.only(bottom: 18),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (pending.value ? Color(0xfff5a623) : Color(0xff25a864))
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  pending.value ? 'Pending' : 'Taken',
                  style: TextStyle(
                    color: pending.value
                        ? Color(0xfff5a623)
                        : Color(0xff25a864),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8),

          Text(
            "$dose",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),

          SizedBox(height: 6),

          Row(
            children: [
              Icon(Icons.access_time_outlined, size: 18, color: Colors.grey[600]),
              SizedBox(width: 6),
              Text(
                time,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          SizedBox(height: 14),

          pending.value
              ? SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff3466f2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 3,
                textStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, size: 18, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Mark as Taken',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
              : SizedBox.shrink(),
        ],
      ),
    ));
  }
}
