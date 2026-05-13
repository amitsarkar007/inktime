import 'package:e_ink_clock/features/weather/weather_code_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps known Open-Meteo weather codes', () {
    expect(weatherCodeToText(0), 'Clear');
    expect(weatherCodeToText(1), 'Mainly clear');
    expect(weatherCodeToText(2), 'Partly cloudy');
    expect(weatherCodeToText(3), 'Overcast');
    expect(weatherCodeToText(48), 'Freezing fog');
    expect(weatherCodeToText(55), 'Drizzle');
    expect(weatherCodeToText(57), 'Freezing drizzle');
    expect(weatherCodeToText(67), 'Freezing rain');
    expect(weatherCodeToText(77), 'Snow grains');
    expect(weatherCodeToText(82), 'Rain showers');
    expect(weatherCodeToText(86), 'Snow showers');
    expect(weatherCodeToText(99), 'Thunderstorm with hail');
  });

  test('maps unknown codes to fallback text', () {
    expect(weatherCodeToText(999), 'Unknown');
  });
}
