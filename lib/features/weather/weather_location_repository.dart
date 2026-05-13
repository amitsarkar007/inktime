import 'package:shared_preferences/shared_preferences.dart';

import 'weather_location_model.dart';

class WeatherLocationRepository {
  static const String _storageKey = 'selected_weather_location';

  Future<WeatherLocationModel?> load() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? encoded = preferences.getString(_storageKey);
    if (encoded == null) {
      return null;
    }
    return WeatherLocationModel.decode(encoded);
  }

  Future<void> save(WeatherLocationModel location) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, location.encode());
  }

  Future<void> clear() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
  }
}
