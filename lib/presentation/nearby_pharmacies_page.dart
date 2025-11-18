import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/nearby_pharmacies_controller.dart';
import '../data/pharmacy_model.dart';

class NearbyPharmaciesPage extends GetView<NearbyPharmaciesController> {
  const NearbyPharmaciesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenHeight = media.size.height;
    final screenWidth = media.size.width;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // ============ الهيدر (عنوان + سيرش) ============
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenHeight * 0.02,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4FC3F7), Color(0xFF81D4FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back + Title
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Get.back(),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Nearby Pharmacies',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Search pharmacies...',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            onChanged: controller.onSearchChanged,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                ],
              ),
            ),

            // ============ الخريطة + الليست في Scroll واحد ============
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: SpinKitPumpingHeart(
                      color: Color(0xFF4FC3F7),
                      size: 50,
                    ),
                  );
                }

                if (controller.errorMessage.value != null) {
                  return Center(
                    child: Text(
                      controller.errorMessage.value!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final elements = controller.filteredPharmacies;
                if (elements.isEmpty) {
                  return const Center(
                    child: Text('No pharmacies found nearby'),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // ===== الماب جوّه كارد مستدير =====
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.06,
                          vertical: screenHeight * 0.015,
                        ),
                        child: _mapCard(elements, screenHeight),
                      ),

                      // ===== All Pharmacies / Get Directions =====
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.06,
                          vertical: screenHeight * 0.008,
                        ),
                        child: Row(
                          children: const [
                            Expanded(
                              child: Text(
                                'All Pharmacies',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  children: [
                                    Icon(Icons.navigation,
                                        size: 18, color: Colors.grey),
                                    SizedBox(width: 4),
                                    Text(
                                      'Get Directions',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ===== الليست نفسها (جزء من نفس الـ scroll) =====
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.06,
                        ),
                        itemCount: elements.length,
                        itemBuilder: (context, index) {
                          final e = elements[index];
                          return _PharmacyCard(
                            element: e,
                            distanceText: controller.distanceTextFor(e),
                            onDirections: () =>
                                _launchDirections(e.lat, e.lon),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ===== خريطة داخل كارد مستدير =====
  Widget _mapCard(List<Elements> elements, double screenHeight) {
    final userPos = controller.userPosition;

    final center = userPos != null
        ? LatLng(userPos.latitude, userPos.longitude)
        : LatLng(elements.first.lat, elements.first.lon);

    final cardHeight = screenHeight * 0.28;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: cardHeight,
        width: double.infinity,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: 14,
            maxZoom: 18,
            minZoom: 3,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.reminder_app',
            ),
            if (userPos != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(userPos.latitude, userPos.longitude),
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 28,
                    ),
                  ),
                ],
              ),
            MarkerLayer(
              markers: elements
                  .map(
                    (e) => Marker(
                      point: LatLng(e.lat, e.lon),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFF4FC3F7),
                        size: 32,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Directions فقط
  Future<void> _launchDirections(double lat, double lon) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ================= الكارت (من غير Call) =================
class _PharmacyCard extends StatelessWidget {
  final Elements element;
  final String distanceText;
  final VoidCallback onDirections;

  const _PharmacyCard({
    Key? key,
    required this.element,
    required this.distanceText,
    required this.onDirections,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tags = element.tags;

    final addressParts = [
      if (tags.addrStreet != null) tags.addrStreet,
      if (tags.addrHousenumber != null) tags.addrHousenumber,
      if (tags.addrCity != null) tags.addrCity,
    ].whereType<String>().toList();

    final address =
        addressParts.isEmpty ? 'No address' : addressParts.join(', ');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الاسم + Open
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  tags.name ?? 'Unknown pharmacy',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Open',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          if (distanceText.isNotEmpty)
            Text(
              distanceText,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),

          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  address,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          if (tags.phone != null && tags.phone!.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    tags.phone!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],

          if (tags.openingHours != null &&
              tags.openingHours!.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.access_time,
                    size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    tags.openingHours!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // زر Directions فقط
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: onDirections,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                backgroundColor: const Color(0xFF2F76FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.navigation,
                        size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Directions',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
