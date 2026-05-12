import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:timezone/timezone.dart' as tz;

import '../../shared/result.dart';
import 'timezone_model.dart';

class TimezoneService {
  TimezoneService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Result<List<TimezoneModel>>> searchCities(String query) async {
    final String trimmed = query.trim();
    if (trimmed.length < 2) {
      return const Success<List<TimezoneModel>>(<TimezoneModel>[]);
    }

    final Uri uri = Uri.https(
      'geocoding-api.open-meteo.com',
      '/v1/search',
      <String, String>{
        'name': trimmed,
        'count': '10',
        'language': 'en',
        'format': 'json',
      },
    );

    try {
      final http.Response response = await _client.get(uri).timeout(
            const Duration(seconds: 20),
          );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return Failure<List<TimezoneModel>>(
          'Geocoding API returned ${response.statusCode}.',
        );
      }

      final Object? decoded = jsonDecode(response.body);
      if (decoded is! Map<String, Object?>) {
        return const Failure<List<TimezoneModel>>('Search response was malformed.');
      }

      final Object? results = decoded['results'];
      if (results == null) {
        return const Success<List<TimezoneModel>>(<TimezoneModel>[]);
      }
      if (results is! List<Object?>) {
        return const Failure<List<TimezoneModel>>('Search response was malformed.');
      }

      final List<TimezoneModel> models = results
          .map(_parseResult)
          .whereType<TimezoneModel>()
          .toList(growable: false);
      return Success<List<TimezoneModel>>(models);
    } on FormatException {
      return const Failure<List<TimezoneModel>>('Search response was malformed.');
    } on Exception catch (error) {
      return Failure<List<TimezoneModel>>('City search failed: $error');
    }
  }

  DateTime timeInTimezone(TimezoneModel model, DateTime utcNow) {
    final tz.Location location = tz.getLocation(model.timezone);
    return tz.TZDateTime.from(utcNow.toUtc(), location);
  }

  List<TimezoneModel> sortByCurrentLocalTime(List<TimezoneModel> models, DateTime utcNow) {
    final List<TimezoneModel> sorted = List<TimezoneModel>.of(models);
    sorted.sort((TimezoneModel a, TimezoneModel b) {
      final DateTime aTime = timeInTimezone(a, utcNow);
      final DateTime bTime = timeInTimezone(b, utcNow);
      final int minuteA = aTime.hour * 60 + aTime.minute;
      final int minuteB = bTime.hour * 60 + bTime.minute;
      final int timeComparison = minuteA.compareTo(minuteB);
      if (timeComparison != 0) {
        return timeComparison;
      }
      return a.city.toLowerCase().compareTo(b.city.toLowerCase());
    });
    return sorted;
  }

  TimezoneModel? _parseResult(Object? value) {
    if (value is! Map<String, Object?>) {
      return null;
    }

    final Object? name = value['name'];
    final Object? country = value['country'];
    final Object? latitude = value['latitude'];
    final Object? longitude = value['longitude'];
    final Object? timezone = value['timezone'];

    if (name is! String ||
        country is! String ||
        latitude is! num ||
        longitude is! num ||
        timezone is! String) {
      return null;
    }

    return TimezoneModel(
      city: name,
      country: country,
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
      timezone: timezone,
    );
  }
}
