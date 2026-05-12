import 'package:e_ink_clock/features/timezones/timezone_model.dart';
import 'package:e_ink_clock/features/timezones/timezone_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('sorts timezones by local HH:mm, then city name', () {
    final TimezoneService service = TimezoneService();
    final List<TimezoneModel> input = <TimezoneModel>[
      const TimezoneModel(
        city: 'Tokyo',
        country: 'Japan',
        latitude: 35.6895,
        longitude: 139.6917,
        timezone: 'Asia/Tokyo',
      ),
      const TimezoneModel(
        city: 'London',
        country: 'United Kingdom',
        latitude: 51.5072,
        longitude: -0.1276,
        timezone: 'Europe/London',
      ),
      const TimezoneModel(
        city: 'Accra',
        country: 'Ghana',
        latitude: 5.6037,
        longitude: -0.187,
        timezone: 'Africa/Accra',
      ),
    ];

    final List<TimezoneModel> sorted = service.sortByCurrentLocalTime(
      input,
      DateTime.utc(2026, 1, 1, 12),
    );

    expect(
      sorted.map((TimezoneModel model) => model.city),
      <String>['Accra', 'London', 'Tokyo'],
    );
  });
}
