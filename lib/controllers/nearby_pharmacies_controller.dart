import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:reminder_app/core/location_permision.dart';
import 'package:reminder_app/services/pharmacies_service.dart';
import 'package:reminder_app/model/pharmacy_model.dart';

class NearbyPharmaciesController extends GetxController {
  final PharmaciesService service = Get.find<PharmaciesService>();

  final isLoading = false.obs;
  final errorMessage = RxnString();

  final pharmacies = <Elements>[].obs;

  final searchText = ''.obs;

  Position? userPosition;

  @override
  void onInit() {
    super.onInit();
    fetchNearbyPharmacies();
  }

    Future<void> fetchNearbyPharmacies() async {
  try {
    isLoading.value = true;
    errorMessage.value = null;

    final pos = await getCurrentPosition();
    userPosition = pos;

    final response = await service.getNearbyPharmacies(
      lat: pos.latitude,
      lon: pos.longitude,
    );

    if (response == null) {
      pharmacies.clear();
      errorMessage.value = 'No pharmacies found nearby';
      return;
    }

    final elements = response.elements;
    if (userPosition != null) {
      elements.sort((a, b) {
        final da = Geolocator.distanceBetween(
          userPosition!.latitude,
          userPosition!.longitude,
          a.lat,
          a.lon,
        );
        final db = Geolocator.distanceBetween(
          userPosition!.latitude,
          userPosition!.longitude,
          b.lat,
          b.lon,
        );
        return da.compareTo(db);
      });
    }
    pharmacies.assignAll(elements);
  } on TimeoutException {
    errorMessage.value =
        'Request took too long.\nPlease check your internet and try again.';
  } catch (e) {
    final msg = e.toString();

    if (msg.contains('SocketException') ||
        msg.contains('Failed host lookup') ||
        msg.contains('No Internet') ||
        msg.contains('network is unreachable')) {
      errorMessage.value =
          'No internet connection.\nPlease check your network and try again.';
    } else if (msg.contains('timeout')) {
      errorMessage.value =
          'Request timed out.\nPlease try again in a moment.';
    } else {
      errorMessage.value =
          'Failed to load nearby pharmacies.\nPlease try again later.';
    }
  } finally {
    isLoading.value = false;
  }
}

  // ============= Search =============

  void onSearchChanged(String value) {
    searchText.value = value.toLowerCase();
  }

  List<Elements> get filteredPharmacies {
    final q = searchText.value;
    if (q.isEmpty) return pharmacies;

    return pharmacies.where((e) {
      final name = e.tags.name?.toLowerCase() ?? '';
      return name.contains(q);
    }).toList();
  }


  String distanceTextFor(Elements e) {
    if (userPosition == null) return '';

    final dMeters = Geolocator.distanceBetween(
      userPosition!.latitude,
      userPosition!.longitude,
      e.lat,
      e.lon,
    );

    if (dMeters >= 1000) {
      final km = dMeters / 1000;
      return '${km.toStringAsFixed(1)} km away';
    } else {
      return '${dMeters.toStringAsFixed(0)} m away';
    }
  }
}
