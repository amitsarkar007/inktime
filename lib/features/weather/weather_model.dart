import '../../shared/date_time_formatters.dart';

class WeatherModel {
  const WeatherModel({
    required this.temperatureCelsius,
    required this.feelsLikeCelsius,
    required this.weatherCode,
    required this.condition,
    required this.highCelsius,
    required this.lowCelsius,
    required this.precipitationMm,
    required this.precipitationProbabilityPercent,
    required this.humidityPercent,
    required this.pressureHpa,
    required this.windSpeedKmh,
    required this.sunrise,
    required this.sunset,
    required this.moonPhase,
    required this.lastUpdated,
    this.uvIndex,
    this.airQualityIndex,
    this.airQualityLabel,
    this.pm25,
    this.pm10,
    this.pollen,
    this.hourlyForecast = const <HourlyForecast>[],
    this.dailyForecast = const <DailyForecast>[],
  });

  final double temperatureCelsius;
  final double feelsLikeCelsius;
  final int weatherCode;
  final String condition;
  final double highCelsius;
  final double lowCelsius;
  final double precipitationMm;
  final int precipitationProbabilityPercent;
  final int humidityPercent;
  final double pressureHpa;
  final double windSpeedKmh;
  final DateTime sunrise;
  final DateTime sunset;
  final String moonPhase;
  final DateTime lastUpdated;
  final double? uvIndex;
  final int? airQualityIndex;
  final String? airQualityLabel;
  final double? pm25;
  final double? pm10;
  final PollenSummary? pollen;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;

  String get sunriseText => format24Hour(sunrise);
  String get sunsetText => format24Hour(sunset);
  String get daylightDurationText {
    final Duration duration = sunset.difference(sunrise);
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }

  String get lastUpdatedText => format24Hour(lastUpdated);
}

class PollenSummary {
  const PollenSummary({
    this.grass,
    this.birch,
    this.alder,
    this.ragweed,
  });

  final double? grass;
  final double? birch;
  final double? alder;
  final double? ragweed;

  bool get hasAny =>
      grass != null || birch != null || alder != null || ragweed != null;

  String get displayText {
    final List<MapEntry<String, double?>> values = <MapEntry<String, double?>>[
      MapEntry<String, double?>('Grass', grass),
      MapEntry<String, double?>('Birch', birch),
      MapEntry<String, double?>('Alder', alder),
      MapEntry<String, double?>('Ragweed', ragweed),
    ].where((MapEntry<String, double?> entry) => entry.value != null).toList();

    if (values.isEmpty) {
      return 'Unavailable';
    }
    values.sort((MapEntry<String, double?> a, MapEntry<String, double?> b) {
      return b.value!.compareTo(a.value!);
    });
    final MapEntry<String, double?> highest = values.first;
    return '${highest.key} ${highest.value!.toStringAsFixed(1)}';
  }
}

class HourlyForecast {
  const HourlyForecast({
    required this.time,
    required this.temperatureCelsius,
    required this.feelsLikeCelsius,
    required this.weatherCode,
    required this.condition,
    required this.precipitationMm,
    required this.precipitationProbabilityPercent,
    required this.windSpeedKmh,
  });

  final DateTime time;
  final double temperatureCelsius;
  final double feelsLikeCelsius;
  final int weatherCode;
  final String condition;
  final double precipitationMm;
  final int precipitationProbabilityPercent;
  final double windSpeedKmh;

  String get timeText => format24Hour(time);
}

class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.condition,
    required this.highCelsius,
    required this.lowCelsius,
    required this.precipitationProbabilityPercent,
    required this.uvIndexMax,
    required this.sunrise,
    required this.sunset,
  });

  final DateTime date;
  final int weatherCode;
  final String condition;
  final double highCelsius;
  final double lowCelsius;
  final int precipitationProbabilityPercent;
  final double? uvIndexMax;
  final DateTime sunrise;
  final DateTime sunset;

  String get dateText => formatDate(date);
  String get sunriseText => format24Hour(sunrise);
  String get sunsetText => format24Hour(sunset);
}
