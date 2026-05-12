import 'dart:convert';

class TimezoneModel {
  const TimezoneModel({
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final String timezone;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
    };
  }

  static TimezoneModel? fromJson(Object? value) {
    if (value is! Map<String, Object?>) {
      return null;
    }
    final Object? city = value['city'];
    final Object? country = value['country'];
    final Object? latitude = value['latitude'];
    final Object? longitude = value['longitude'];
    final Object? timezone = value['timezone'];

    if (city is! String ||
        country is! String ||
        latitude is! num ||
        longitude is! num ||
        timezone is! String) {
      return null;
    }

    return TimezoneModel(
      city: city,
      country: country,
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
      timezone: timezone,
    );
  }

  String encode() {
    return jsonEncode(toJson());
  }

  static TimezoneModel? decode(String value) {
    try {
      return fromJson(jsonDecode(value));
    } on FormatException {
      return null;
    }
  }
}
