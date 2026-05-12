import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../shared/result.dart';

class LocationService {
  Future<Result<Position>> getOneShotPosition() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const Failure<Position>('Location services are unavailable.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        return const Failure<Position>('Location permission was denied.');
      }

      if (permission == LocationPermission.deniedForever) {
        return const Failure<Position>(
          'Location permission is permanently denied. Enable it in system settings.',
        );
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return Success<Position>(position);
    } on Exception catch (error) {
      return Failure<Position>('Could not read location: $error');
    }
  }

  Future<String?> describePosition(Position position) async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 8));
      if (placemarks.isEmpty) {
        return null;
      }

      final Placemark place = placemarks.first;
      final String? locationName = _firstNonEmpty(<String?>[
        place.locality,
        place.subAdministrativeArea,
        place.subLocality,
        place.administrativeArea,
      ]);
      final String? countryName = _countryLabel(place);
      if (locationName == null && countryName == null) {
        return null;
      }
      if (locationName == null) {
        return countryName;
      }
      if (countryName == null || countryName == locationName) {
        return locationName;
      }
      return '$locationName, $countryName';
    } on Exception {
      return null;
    }
  }

  String? _firstNonEmpty(List<String?> values) {
    for (final String? value in values) {
      final String trimmed = (value ?? '').trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }

  String? _countryLabel(Placemark place) {
    final String isoCode = (place.isoCountryCode ?? '').trim().toUpperCase();
    if (isoCode == 'GB') {
      return 'UK';
    }
    if (isoCode.isNotEmpty && isoCode.length <= 3) {
      return isoCode;
    }
    final String country = (place.country ?? '').trim();
    return country.isEmpty ? null : country;
  }
}
