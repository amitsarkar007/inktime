import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../shared/result.dart';
import 'weather_code_mapper.dart';
import 'weather_model.dart';

class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Result<WeatherModel>> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    final _AirQualityData? airQuality = await _fetchAirQuality(
      latitude: latitude,
      longitude: longitude,
    );
    final Uri uri = Uri.https('api.open-meteo.com', '/v1/forecast', <String, String>{
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current':
          'temperature_2m,apparent_temperature,relative_humidity_2m,weather_code,precipitation,wind_speed_10m,pressure_msl',
      'hourly':
          'temperature_2m,apparent_temperature,weather_code,precipitation,precipitation_probability,wind_speed_10m',
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,uv_index_max,sunrise,sunset',
      'temperature_unit': 'celsius',
      'wind_speed_unit': 'kmh',
      'precipitation_unit': 'mm',
      'timezone': 'auto',
      'forecast_days': '6',
    });

    try {
      final http.Response response = await _client.get(uri).timeout(
            const Duration(seconds: 20),
          );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return Failure<WeatherModel>('Weather API returned ${response.statusCode}.');
      }

      final Object? decoded = jsonDecode(response.body);
      if (decoded is! Map<String, Object?>) {
        return const Failure<WeatherModel>('Weather response was malformed.');
      }

      final Object? currentObject = decoded['current'];
      final Object? hourlyObject = decoded['hourly'];
      final Object? dailyObject = decoded['daily'];
      if (currentObject is! Map<String, Object?> ||
          hourlyObject is! Map<String, Object?> ||
          dailyObject is! Map<String, Object?>) {
        return const Failure<WeatherModel>('Weather response was missing required data.');
      }

      final WeatherModel model = WeatherModel(
        temperatureCelsius: _asDouble(currentObject['temperature_2m']),
        feelsLikeCelsius: _asDouble(currentObject['apparent_temperature']),
        weatherCode: _asInt(currentObject['weather_code']),
        condition: weatherCodeToText(_asInt(currentObject['weather_code'])),
        highCelsius: _firstDouble(dailyObject['temperature_2m_max']),
        lowCelsius: _firstDouble(dailyObject['temperature_2m_min']),
        precipitationMm: _asDouble(currentObject['precipitation']),
        precipitationProbabilityPercent:
            _firstInt(dailyObject['precipitation_probability_max']),
        humidityPercent: _asInt(currentObject['relative_humidity_2m']),
        pressureHpa: _asDouble(currentObject['pressure_msl']),
        windSpeedKmh: _asDouble(currentObject['wind_speed_10m']),
        sunrise: _firstDateTime(dailyObject['sunrise']),
        sunset: _firstDateTime(dailyObject['sunset']),
        moonPhase: _moonPhaseText(DateTime.now()),
        lastUpdated: DateTime.now(),
        uvIndex: airQuality?.uvIndex,
        airQualityIndex: airQuality?.europeanAqi,
        airQualityLabel: _airQualityLabel(airQuality?.europeanAqi),
        pm25: airQuality?.pm25,
        pm10: airQuality?.pm10,
        pollen: airQuality?.pollen,
        hourlyForecast: _parseHourlyForecast(hourlyObject, DateTime.now()),
        dailyForecast: _parseDailyForecast(dailyObject),
      );
      return Success<WeatherModel>(model);
    } on FormatException {
      return const Failure<WeatherModel>('Weather response was malformed.');
    } on Exception catch (error) {
      return Failure<WeatherModel>('Weather could not be loaded: $error');
    }
  }

  Future<_AirQualityData?> _fetchAirQuality({
    required double latitude,
    required double longitude,
  }) async {
    final Uri uri = Uri.https(
      'air-quality-api.open-meteo.com',
      '/v1/air-quality',
      <String, String>{
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current': 'european_aqi,pm2_5,pm10,uv_index',
        'timezone': 'auto',
      },
    );

    try {
      final http.Response response = await _client.get(uri).timeout(
            const Duration(seconds: 20),
          );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      final Object? decoded = jsonDecode(response.body);
      if (decoded is! Map<String, Object?>) {
        return null;
      }
      final Object? currentObject = decoded['current'];
      if (currentObject is! Map<String, Object?>) {
        return null;
      }
      final PollenSummary? pollen = await _fetchPollen(
        latitude: latitude,
        longitude: longitude,
      );
      return _AirQualityData(
        europeanAqi: _asInt(currentObject['european_aqi']),
        pm25: _asDouble(currentObject['pm2_5']),
        pm10: _asDouble(currentObject['pm10']),
        uvIndex: _asDouble(currentObject['uv_index']),
        pollen: pollen,
      );
    } on Exception {
      return null;
    }
  }

  Future<PollenSummary?> _fetchPollen({
    required double latitude,
    required double longitude,
  }) async {
    final Uri uri = Uri.https(
      'air-quality-api.open-meteo.com',
      '/v1/air-quality',
      <String, String>{
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current': 'grass_pollen,birch_pollen,alder_pollen,ragweed_pollen',
        'timezone': 'auto',
      },
    );

    try {
      final http.Response response = await _client.get(uri).timeout(
            const Duration(seconds: 20),
          );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      final Object? decoded = jsonDecode(response.body);
      if (decoded is! Map<String, Object?>) {
        return null;
      }
      final Object? currentObject = decoded['current'];
      if (currentObject is! Map<String, Object?>) {
        return null;
      }
      final PollenSummary pollen = PollenSummary(
        grass: _nullableDouble(currentObject['grass_pollen']),
        birch: _nullableDouble(currentObject['birch_pollen']),
        alder: _nullableDouble(currentObject['alder_pollen']),
        ragweed: _nullableDouble(currentObject['ragweed_pollen']),
      );
      return pollen.hasAny ? pollen : null;
    } on Exception {
      return null;
    }
  }

  double _asDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    throw const FormatException('Expected number.');
  }

  double? _nullableDouble(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }

  int _asInt(Object? value) {
    if (value is num) {
      return value.toInt();
    }
    throw const FormatException('Expected integer.');
  }

  double _firstDouble(Object? value) {
    if (value is List<Object?> && value.isNotEmpty) {
      return _asDouble(value.first);
    }
    throw const FormatException('Expected number list.');
  }

  int _firstInt(Object? value) {
    if (value is List<Object?> && value.isNotEmpty) {
      return _asInt(value.first);
    }
    throw const FormatException('Expected integer list.');
  }

  DateTime _firstDateTime(Object? value) {
    if (value is List<Object?> && value.isNotEmpty) {
      final Object? first = value.first;
      if (first is String) {
        return DateTime.parse(first);
      }
    }
    throw const FormatException('Expected date-time list.');
  }

  List<HourlyForecast> _parseHourlyForecast(
    Map<String, Object?> hourly,
    DateTime now,
  ) {
    final Object? times = hourly['time'];
    final Object? temperatures = hourly['temperature_2m'];
    final Object? feelsLike = hourly['apparent_temperature'];
    final Object? weatherCodes = hourly['weather_code'];
    final Object? precipitation = hourly['precipitation'];
    final Object? precipitationProbability = hourly['precipitation_probability'];
    final Object? windSpeeds = hourly['wind_speed_10m'];
    if (times is! List<Object?> ||
        temperatures is! List<Object?> ||
        feelsLike is! List<Object?> ||
        weatherCodes is! List<Object?> ||
        precipitation is! List<Object?> ||
        precipitationProbability is! List<Object?> ||
        windSpeeds is! List<Object?>) {
      return const <HourlyForecast>[];
    }

    final DateTime today = DateTime(now.year, now.month, now.day);
    final List<HourlyForecast> forecasts = <HourlyForecast>[];
    for (int i = 0; i < times.length; i += 1) {
      if (times[i] is! String) {
        continue;
      }
      final DateTime time = DateTime.parse(times[i]! as String);
      final DateTime date = DateTime(time.year, time.month, time.day);
      if (date != today || !time.isAfter(now)) {
        continue;
      }
      forecasts.add(
        HourlyForecast(
          time: time,
          temperatureCelsius: _asDouble(temperatures[i]),
          feelsLikeCelsius: _asDouble(feelsLike[i]),
          weatherCode: _asInt(weatherCodes[i]),
          condition: weatherCodeToText(_asInt(weatherCodes[i])),
          precipitationMm: _asDouble(precipitation[i]),
          precipitationProbabilityPercent: _asInt(precipitationProbability[i]),
          windSpeedKmh: _asDouble(windSpeeds[i]),
        ),
      );
    }
    return forecasts.take(12).toList(growable: false);
  }

  List<DailyForecast> _parseDailyForecast(Map<String, Object?> daily) {
    final Object? times = daily['time'];
    final Object? weatherCodes = daily['weather_code'];
    final Object? highs = daily['temperature_2m_max'];
    final Object? lows = daily['temperature_2m_min'];
    final Object? precipitationProbability = daily['precipitation_probability_max'];
    final Object? uvMax = daily['uv_index_max'];
    final Object? sunrises = daily['sunrise'];
    final Object? sunsets = daily['sunset'];
    if (times is! List<Object?> ||
        weatherCodes is! List<Object?> ||
        highs is! List<Object?> ||
        lows is! List<Object?> ||
        precipitationProbability is! List<Object?> ||
        uvMax is! List<Object?> ||
        sunrises is! List<Object?> ||
        sunsets is! List<Object?>) {
      return const <DailyForecast>[];
    }

    final List<DailyForecast> forecasts = <DailyForecast>[];
    for (int i = 1; i < times.length && forecasts.length < 5; i += 1) {
      if (times[i] is! String || sunrises[i] is! String || sunsets[i] is! String) {
        continue;
      }
      forecasts.add(
        DailyForecast(
          date: DateTime.parse(times[i]! as String),
          weatherCode: _asInt(weatherCodes[i]),
          condition: weatherCodeToText(_asInt(weatherCodes[i])),
          highCelsius: _asDouble(highs[i]),
          lowCelsius: _asDouble(lows[i]),
          precipitationProbabilityPercent: _asInt(precipitationProbability[i]),
          uvIndexMax: _nullableDouble(uvMax[i]),
          sunrise: DateTime.parse(sunrises[i]! as String),
          sunset: DateTime.parse(sunsets[i]! as String),
        ),
      );
    }
    return forecasts;
  }

  String? _airQualityLabel(int? europeanAqi) {
    if (europeanAqi == null) {
      return null;
    }
    if (europeanAqi <= 20) {
      return 'Good';
    }
    if (europeanAqi <= 40) {
      return 'Fair';
    }
    if (europeanAqi <= 60) {
      return 'Moderate';
    }
    if (europeanAqi <= 80) {
      return 'Poor';
    }
    if (europeanAqi <= 100) {
      return 'Very poor';
    }
    return 'Extremely poor';
  }

  String _moonPhaseText(DateTime date) {
    const double lunarCycleDays = 29.530588853;
    final DateTime knownNewMoon = DateTime.utc(2000, 1, 6, 18, 14);
    final double daysSinceKnownNewMoon =
        date.toUtc().difference(knownNewMoon).inHours / 24;
    final double age = daysSinceKnownNewMoon % lunarCycleDays;
    if (age < 1.84566) {
      return 'New moon';
    }
    if (age < 5.53699) {
      return 'Waxing crescent';
    }
    if (age < 9.22831) {
      return 'First quarter';
    }
    if (age < 12.91963) {
      return 'Waxing gibbous';
    }
    if (age < 16.61096) {
      return 'Full moon';
    }
    if (age < 20.30228) {
      return 'Waning gibbous';
    }
    if (age < 23.99361) {
      return 'Last quarter';
    }
    if (age < 27.68493) {
      return 'Waning crescent';
    }
    return 'New moon';
  }
}

class _AirQualityData {
  const _AirQualityData({
    required this.europeanAqi,
    required this.pm25,
    required this.pm10,
    required this.uvIndex,
    this.pollen,
  });

  final int europeanAqi;
  final double pm25;
  final double pm10;
  final double uvIndex;
  final PollenSummary? pollen;
}
