import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:reminder_app/controllers/medications_controller.dart';
import 'package:reminder_app/controllers/navigation_controller.dart';
import 'package:reminder_app/data/entity/medications.dart';
import '../theme/app_theme.dart';

class MedicationsPage extends GetView<MedicationsController> {
  const MedicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MedicationsController>()) {
      Get.put(MedicationsController());
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        toolbarHeight: 80,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: isDark ? AppColors.darkGradient : AppColors.lightGradient,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
                    onPressed: () {
                      final nav = Get.find<NavigationController>();
                      nav.navigateToIndex(0);
                    },
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'My Medications'.tr,
                      maxLines: 2,
                      softWrap: true,
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge!.color,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: theme.iconTheme.color,
                    ),
                    onPressed: () => Get.toNamed('/addMedication'),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Obx(() {
            final count = controller.medications.length;
            return Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 10),
              child: Row(
                children: [
                  Text(
                    '${'activeMedicationCount'.trParams({'count': '$count'})}',   //////// <----------- here the change '$count active medication.${count == 1 ? '' : 's'}'.tr,
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium!.color,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: SpinKitPumpingHeart(color: theme.primaryColor, size: 50),
          );
        }

        if (controller.medications.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.medication_outlined, size: 64, color: theme.textTheme.bodyMedium!.color),
                const SizedBox(height: 10),
                Text(
                  'No active medications yet'.tr,
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium!.color,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap + to add your first medication'.tr,
                  style: TextStyle(color: theme.textTheme.bodyMedium!.color, fontSize: 13),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.medications.length,
          itemBuilder: (context, index) {
            final med = controller.medications[index];
            return _buildMedicationCard(context, med);
          },
        );
      }),
    );
  }

  Widget _buildMedicationCard(BuildContext context, Medication med) {
    final c = Get.find<MedicationsController>();
    final nextRaw = (med.medId != null) ? c.nextDoseTimes[med.medId!] : null;
    final nextDoseText = nextRaw != null
        ? c.formatTimeForDisplay(nextRaw)
        : '—';

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16), // زودنا الـ Padding شوية للراحة
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20), // تدوير الحواف أكتر (Modern)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header: Icon + Name ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  if (med.imageUrl != null && med.imageUrl!.isNotEmpty) {
                    // ... (نفس كود عرض الصورة القديم)
                  }
                },
                child: Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: AppColors.primary.withOpacity(0.1), // خلفية لبني هادية
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: (med.imageUrl != null && med.imageUrl!.isNotEmpty)
                      ? Image.file(File(med.imageUrl!), fit: BoxFit.cover)
                      : Icon(
                    Icons.medication_rounded, // أيقونة مدورة
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      med.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge!.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${med.dosage} • ${med.frequency}',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium!.color,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // --- Info Chips (Next Dose & Duration) ---
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor, // خلفية حيادية
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 14, color: AppColors.secondary),
                          const SizedBox(width: 4),
                          Text('Next dose', style: TextStyle(fontSize: 10, color: theme.textTheme.bodyMedium!.color)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nextDoseText,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary // الأزرق الغامق للقراءة
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.secondary),
                          const SizedBox(width: 4),
                          Text('Duration', style: TextStyle(fontSize: 10, color: theme.textTheme.bodyMedium!.color)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        med.durationOfUse,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // --- Notes (If any) ---
          if (med.notes != null && med.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1), // أصفر هادي جداً
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.sticky_note_2_outlined, size: 16, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      med.notes!,
                      style: TextStyle(fontSize: 12, color: theme.textTheme.bodyLarge!.color),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // --- Action Buttons (New Style) ---
          Row(
            children: [
              // زر التعديل (أزرق مفرغ)
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditDialog(context, med),
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: Text('Edit'.tr),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: TextButton.icon(
                    onPressed: () => _showDeleteDialog(context, med),
                    icon: Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                    label: Text(
                        'Delete'.tr,
                        style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.error.withOpacity(0.1), // خلفية حمراء باهتة جداً
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Medication med) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.error.withOpacity(0.1), // دائرة حمراء شفافة
                  ),
                  child: Icon(
                    Icons.delete_forever_rounded,
                    color: AppColors.error, // أيقونة حمراء
                    size: 32,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Delete Medication?'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: theme.textTheme.bodyLarge!.color,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to delete "${med.name}"?\nThis action cannot be undone.'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium!.color,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.textTheme.bodyLarge!.color,
                          ),
                          child: Text('Cancel'.tr, style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error, // الأحمر الناعم
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            final c = Get.find<MedicationsController>();
                            c.deleteMedication(med);
                          },
                          child: Text(
                            'Delete'.tr,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, Medication med) async {
    await controller.loadScheduleForEdit(med);

    final theme = Theme.of(context);
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
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Obx(
                      () => SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                          decoration: BoxDecoration(
                            gradient: AppColors.lightGradient, // استخدم الجرادينت الموحد
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.edit_calendar_rounded, color: Colors.white, size: 26),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Edit Schedule'.tr,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        Text(
                          'Frequency'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: controller.editFrequency.value.isEmpty
                              ? null
                              : controller.editFrequency.value,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            filled: true,
                            fillColor: theme.scaffoldBackgroundColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: theme.textTheme.bodyMedium!.color!.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: theme.primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                          hint: Text(
                            'Select frequency'.tr,
                            style: TextStyle(color: theme.textTheme.bodyMedium!.color, fontSize: 13),
                          ),
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: theme.primaryColor,
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textTheme.bodyLarge!.color,
                          ),
                          dropdownColor: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          items:
                           [ ///remove const
                            'Once daily'.tr,
                            'Twice daily (2x/day)'.tr,
                            'Three times daily (3x/day)'.tr,
                            'Four times daily (4x/day)'.tr,
                            'As needed'.tr,
                          ].map((v) {
                            return DropdownMenuItem(
                              value: v,
                              child: Text(
                                v,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.textTheme.bodyLarge!.color,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              controller.onEditFrequencyChanged(val);
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        Text(
                          'Dose Times'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),

                        GestureDetector(
                          onTap: () async {
                            final selectedTime = await showTimePicker(
                              context: ctx,
                              initialTime: TimeOfDay.now(),
                              builder: (BuildContext context, Widget? child) {
                                final theme = Theme.of(context);
                                return MediaQuery(
                                  data: MediaQuery.of(
                                    context,
                                  ).copyWith(alwaysUse24HourFormat: false),
                                  child: Theme(
                                    data: theme.copyWith(
                                      colorScheme: theme.colorScheme.copyWith(
                                        primary: theme.primaryColor,
                                        onPrimary: theme.colorScheme.onPrimary,
                                        surface: theme.cardColor,
                                        onSurface: theme.textTheme.bodyLarge!.color,
                                      ),
                                    ),
                                    child: Center(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: child!,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );

                            if (selectedTime != null) {
                              controller.addDoseTimeForEdit(selectedTime);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: theme.textTheme.bodyMedium!.color!.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Add Dose Time'.tr,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                Icon(Icons.add_alarm, color: theme.primaryColor),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (controller.editDoseTimes.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.cardColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'No dose times added yet'.tr,
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium!.color,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          )
                        else
                          Column(
                            children: controller.editDoseTimes
                                .asMap()
                                .entries
                                .map(
                                  (entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.alarm,
                                        color: theme.primaryColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          controller.formatTimeOfDay(
                                            entry.value,
                                          ),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: theme.textTheme.bodyLarge!.color,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => controller
                                            .removeDoseTimeForEdit(
                                          entry.key,
                                        ),
                                        icon: const Icon(
                                          Icons.close,
                                          size: 18,
                                        ),
                                        color: Colors.red,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                                .toList(),
                          ),
                        const SizedBox(height: 24),

                        Obx(
                              () => SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () {
                                if (controller.editFrequency.value.isEmpty ||
                                    controller.editDoseTimes.isEmpty) {
                                  Get.snackbar(
                                    'Error'.tr,
                                    'Please choose frequency and at least one dose time'.tr,
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                  return;
                                }
                                controller.saveEditedSchedule(med);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                disabledBackgroundColor: theme
                                    .primaryColor.withOpacity(0.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: SpinKitPumpingHeart(
                                    color: Colors.white,
                                    size: 25.0,
                                  )
                              )
                                  : FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize:
                                  MainAxisSize.min,
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children:  [//remove cost
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Save Changes'.tr,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: theme.primaryColor,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancel'.tr,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}