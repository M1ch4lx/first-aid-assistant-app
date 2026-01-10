import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  Future<String> fetchCurrentAddress() async {
    try {
      bool hasPermission = await _handleLocationPermission();
      if (!hasPermission) return "Brak uprawnień do lokalizacji";

      if (kIsWeb) {
        return "Lokalizacja niedostępna w wersji web";
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark p = placemarks[0];
        return "${p.locality}, ${p.street} ${p.name ?? ''}".trim();
      }

      return "Nie rozpoznano adresu";
    } catch (e) {
      return "Błąd GPS lub sieci";
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }
}