import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reminder_app/controllers/home_controller.dart';
import 'package:reminder_app/data/entity/intake_records.dart';
import 'package:reminder_app/data/entity/medications.dart';
import 'package:reminder_app/services/connectivity_service.dart';

class HomePage extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(h, w, controller),
              const SizedBox(height: 14),

              // Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.flash_on_rounded,
                          size: 16,
                          color: Color(0xFF4FC3F7),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _quickActionButton(
                            Icons.add_circle_rounded,
                            'Add Med',
                            const Color(0xFF4FC3F7),
                            () => Get.toNamed('/addMedication'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _quickActionButton(
                            Icons.format_list_bulleted_rounded,
                            'Med Log',
                            const Color(0xFF66BB6A),
                            () => Get.toNamed('/medicationLog'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
  child: _quickActionButton(
    Icons.local_pharmacy_rounded,
    'Pharmacies',
    const Color(0xFFFF7043),
    () async {
      final connectivityService = Get.find<ConnectivityService>();
      final connected = await connectivityService.connected();
      if (!connected) {
        Get.snackbar(
          'No internet',
          'You need an internet connection to view nearby pharmacies.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(10),
          borderRadius: 8,
        );
        return;
      }

      Get.toNamed('/nearbyPharmacies');
    },
  ),
),

                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Today's Schedule Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: Color(0xFF4FC3F7),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "Today's Schedule",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Get.toNamed('/medicationLog'),
                      child: const Text(
                        "View All",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF4FC3F7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Schedule Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.todaysRecords.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(
                          color: Color(0xFF4FC3F7),
                        ),
                      ),
                    );
                  }

                  if (controller.todaysRecords.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No doses scheduled for today',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    );
                  }

                  return Column(
                    children: List.generate(
                      controller.todaysRecords.length,
                      (index) {
                        final IntakeRecord record =
                            controller.todaysRecords[index];
                        final Medication med =
                            controller.todaysMeds[index];

                        final time =
                            controller.formatTime(record.scheduledAt);
                        final status = record.status;
                        final isPending = status == 'pending';

                        Color statusColor;
                        String statusText;
                        switch (status) {
                          case 'taken':
                            statusColor = const Color(0xFF25A864);
                            statusText = 'Taken';
                            break;
                          case 'missed':
                            statusColor = const Color(0xFFE57373);
                            statusText = 'Missed';
                            break;
                          default:
                            statusColor = const Color(0xFFF5A623);
                            statusText = 'Pending';
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // الاسم + حالة Pending/Taken
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      med.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      statusText,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 4),

                              // الجرعة + التكرار
                              Text(
                                '${med.dosage} • ${med.frequency}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),

                              const SizedBox(height: 4),

                              // الوقت
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_outlined,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    time,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),

                              // زر Mark as Taken لو Pending فقط
                              if (isPending) ...[
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  height: 38,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _showIntakeDialog(
                                        context,
                                        controller,
                                        record,
                                        med,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFF4FC3F7),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.check_circle_outline,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Mark as Taken',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== Dialog لاختيار Taken / Missed =====

void _showIntakeDialog(
  BuildContext context,
  HomeController controller,
  IntakeRecord record,
  Medication med,
) {
  final time = controller.formatTime(record.scheduledAt);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final w = MediaQuery.of(ctx).size.width;

      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: w * 0.9,
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Medication Intake',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Did you take your medication?',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE3F2FD),
                    ),
                    child: const Icon(
                      Icons.access_time,
                      color: Color(0xFF42A5F5),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    med.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    med.dosage,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Scheduled: $time',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () async {
                              await controller.markAsTaken(record);
                              Navigator.of(ctx).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 1,
                            ),
                            child: const Text(
                              'Yes, I took it',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            onPressed: () async {
                              await controller.markAsMissed(record);
                              Navigator.of(ctx).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFFE57373),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "No, I missed it",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE57373),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildHeader(double h, double w, HomeController controller) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF4FC3F7), Color(0xFF81D4FA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 3),
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                'assets/images/logo.png',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
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

        const SizedBox(height: 16),

Row(
  children: [
    Obx(
      () => Text(
        controller.greeting.value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    const Spacer(),
    const Icon(
      Icons.nightlight_outlined,
      color: Colors.white70,
      size: 22,
    ),
    const SizedBox(width: 8),
    const Icon(
      Icons.notifications_none,
      color: Colors.white70,
      size: 22,
    ),
  ],
),

        const SizedBox(height: 6),

        Obx(
          () => Text(
            controller.currentDate.value,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Time',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Obx(
                    () => Text(
                      controller.currentTime.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10),
                child: const Icon(
                  Icons.access_time,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _quickActionButton(
  IconData icon,
  String label,
  Color color,
  VoidCallback onTap,
) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}
