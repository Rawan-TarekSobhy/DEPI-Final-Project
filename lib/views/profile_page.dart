import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:reminder_app/controllers/profile_controller.dart';
import 'package:reminder_app/data/entity/users.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final h = media.size.height;
    final w = media.size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: SpinKitPumpingHeart(
                color: Color(0xFF4FC3F7),
                size: 50,
              ),
            );
          }

          final u = controller.user.value;
          if (u == null) {
            return const Center(
              child: Text(
                'No user data found',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.06,
              vertical: h * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar with gradient
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF4FC3F7), Color(0xFF81D4FA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                // Name
                Text(
                  u.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),

                // Subtitle
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: h * 0.03),

                // Settings / Documents cards
                Row(
                  children: [
                    Expanded(
                      child: _smallCard(
                        icon: Icons.settings,
                        title: 'Settings',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _smallCard(
                        icon: Icons.description_outlined,
                        title: 'Documents',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: h * 0.02),

                // Personal info card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with Edit button
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Personal Information',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: Color(0xFF4FC3F7),
                            ),
                            onPressed: () => _showEditDialog(context, u),
                          ),
                          const Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF4FC3F7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // User info rows
                      _infoRow('Full Name', u.name),
                      _infoRow('Age', u.age ?? '—'),
                      _infoRow('Email', u.email),
                      _infoRow('Gender', u.gender ?? '—'),
                      const SizedBox(height: 4),
                      _infoRow('Blood Type', u.bloodType ?? '—'),
                      _infoRow('Height', u.height ?? '—'),
                      _infoRow('Weight', u.weight ?? '—'),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _smallCard({required IconData icon, required String title}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF4FC3F7)),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, User u) {
    final nameCtrl = TextEditingController(text: u.name);
    final ageCtrl = TextEditingController(text: u.age ?? '');
    final emailCtrl = TextEditingController(text: u.email);
    final genderCtrl = TextEditingController(text: u.gender ?? '');
    final bloodCtrl = TextEditingController(text: u.bloodType ?? '');
    final heightCtrl = TextEditingController(text: u.height ?? '');
    final weightCtrl = TextEditingController(text: u.weight ?? '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        final w = MediaQuery.of(context).size.width;
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: w * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with gradient background
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4FC3F7), Color(0xFF81D4FA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Edit Personal Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Full name + Age
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _textField('Full Name', nameCtrl),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: _textField(
                              'Age',
                              ageCtrl,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Email
                      _textField(
                        'Email',
                        emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),

                      // Gender
                      _textField('Gender', genderCtrl),
                      const SizedBox(height: 12),

                      // Blood Type, Height, Weight
                      Row(
                        children: [
                          Expanded(
                            child: _textField('Blood Type', bloodCtrl),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _textField('Height', heightCtrl),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _textField('Weight', weightCtrl),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Save Button with loading state
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () {
                                    final updated = User(
                                      userId: u.userId,
                                      name: nameCtrl.text.trim(),
                                      email: emailCtrl.text.trim(),
                                      password: u.password,
                                      gender: genderCtrl.text.trim().isEmpty
                                          ? null
                                          : genderCtrl.text.trim(),
                                      age: ageCtrl.text.trim().isEmpty
                                          ? null
                                          : ageCtrl.text.trim(),
                                      bloodType:
                                          bloodCtrl.text.trim().isEmpty
                                              ? null
                                              : bloodCtrl.text.trim(),
                                      height: heightCtrl.text.trim().isEmpty
                                          ? null
                                          : heightCtrl.text.trim(),
                                      weight: weightCtrl.text.trim().isEmpty
                                          ? null
                                          : weightCtrl.text.trim(),
                                      syncStatus: 'not_synced',
                                    );

                                    controller.saveUser(updated);

                                    // Close dialog after short delay
                                    Future.delayed(
                                      const Duration(milliseconds: 500),
                                      () {
                                        if (Navigator.canPop(context)) {
                                          Navigator.of(context).pop();
                                        }
                                      },
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4FC3F7),
                              disabledBackgroundColor:
                                  const Color(0xFF4FC3F7).withOpacity(0.6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.check_circle_outline,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Save Changes',
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

                      // Cancel Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF4FC3F7),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4FC3F7),
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
          );
        });
  }

  Widget _textField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4FC3F7),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            filled: true,
            fillColor: const Color(0xFFF5F7FB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF4FC3F7),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
