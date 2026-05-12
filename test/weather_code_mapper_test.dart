import 'package:e_ink_clock/features/weather/weather_code_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps known Open-Meteo weather codes', () {
    expect(weatherCodeToText(0), 'Clear');
    expect(weatherCodeToText(2), 'Partly cloudy');
    expect(weatherCodeToText(48), 'Fog');
    expect(weatherCodeToText(57), 'Drizzle');
    expect(weatherCodeToText(67), 'Rain');
    expect(weatherCodeToText(77), 'Snow');
    expect(weatherCodeToText(82), 'Showers');
    expect(weatherCodeToText(86), 'Snow showers');
    expect(weatherCodeToText(99), 'Thunderstorm');
  });

  test('maps unknown codes to fallback text', () {
    expect(weatherCodeToText(999), 'Unknown');
  });
}
