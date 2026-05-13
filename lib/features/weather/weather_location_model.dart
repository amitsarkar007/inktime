import 'dart:convert';

import '../timezones/timezone_model.dart';

class WeatherLocationModel {
  const WeatherLocationModel({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String country;
  final double latitude;
  final double longitude;

  String get label => '$name, $country';

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'name': name,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  static WeatherLocationModel fromTimezone(TimezoneModel model) {
    return WeatherLocationModel(
      name: model.city,
      country: model.country,
      latitude: model.latitude,
      longitude: model.longitude,
    );
  }

  static WeatherLocationModel? fromJson(Object? value) {
    if (value is! Map<String, Object?>) {
      return null;
    }
    final Object? name = value['name'];
    final Object? country = value['country'];
    final Object? latitude = value['latitude'];
    final Object? longitude = value['longitude'];
    if (name is! String || country is! String || latitude is! num || longitude is! num) {
      return null;
    }
    return WeatherLocationModel(
      name: name,
      country: country,
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
    );
  }

  String encode() {
    return jsonEncode(toJson());
  }

  static WeatherLocationModel? decode(String value) {
    try {
      return fromJson(jsonDecode(value));
    } on FormatException {
      return null;
    }
  }
}
