import 'package:shared_preferences/shared_preferences.dart';

import 'timezone_model.dart';

class TimezoneRepository {
  static const String _storageKey = 'saved_timezones';

  Future<List<TimezoneModel>> load() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final List<String> encoded = preferences.getStringList(_storageKey) ?? <String>[];
    return encoded
        .map(TimezoneModel.decode)
        .whereType<TimezoneModel>()
        .toList(growable: false);
  }

  Future<void> save(List<TimezoneModel> timezones) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _storageKey,
      timezones.map((TimezoneModel timezone) => timezone.encode()).toList(),
    );
  }
}
