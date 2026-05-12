import 'package:flutter/material.dart';

import '../../shared/error_view.dart';
import 'weather_model.dart';
import 'weather_symbol.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({
    required this.weather,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
    super.key,
  });

  final WeatherModel? weather;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'WEATHER',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            IconButton(
              tooltip: 'Refresh weather',
              onPressed: isLoading ? null : onRefresh,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (isLoading && weather == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Loading weather...'),
          )
        else if (errorMessage != null && weather == null)
          ErrorView(message: errorMessage!, onRetry: onRefresh)
        else if (weather != null)
          _WeatherValues(weather: weather!, isRefreshing: isLoading),
        if (errorMessage != null && weather != null) ...<Widget>[
          const SizedBox(height: 12),
          Text(errorMessage!, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ],
    );
  }
}

class _WeatherValues extends StatelessWidget {
  const _WeatherValues({
    required this.weather,
    required this.isRefreshing,
  });

  final WeatherModel weather;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            WeatherSymbol(code: weather.weatherCode, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${weather.temperatureCelsius.toStringAsFixed(1)}\u00B0C',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 30,
                      fontWeight: FontWeight.w300,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(weather.condition, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.air, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${weather.windSpeedKmh.toStringAsFixed(1)} km/h',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Humidity ${weather.humidityPercent}%',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 18),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.55,
          crossAxisSpacing: 12,
          mainAxisSpacing: 8,
          children: <Widget>[
            _Metric(
              icon: Icons.arrow_upward,
              label: 'High',
              value: '${weather.highCelsius.toStringAsFixed(1)}\u00B0C',
            ),
            _Metric(
              icon: Icons.arrow_downward,
              label: 'Low',
              value: '${weather.lowCelsius.toStringAsFixed(1)}\u00B0C',
            ),
            _Metric(
              icon: Icons.device_thermostat,
              label: 'Feels like',
              value: '${weather.feelsLikeCelsius.toStringAsFixed(1)}\u00B0C',
            ),
            _Metric(
              icon: Icons.wb_sunny_outlined,
              label: 'UV index',
              value: weather.uvIndex == null ? 'Unavailable' : weather.uvIndex!.toStringAsFixed(1),
            ),
            _Metric(
              icon: Icons.water_drop_outlined,
              label: 'Precipitation',
              value: '${weather.precipitationMm.toStringAsFixed(1)} mm',
            ),
            _Metric(
              icon: Icons.percent,
              label: 'Probability',
              value: '${weather.precipitationProbabilityPercent}%',
            ),
            _Metric(
              icon: Icons.air,
              label: 'Wind',
              value: '${weather.windSpeedKmh.toStringAsFixed(1)} km/h',
            ),
            _Metric(
              icon: Icons.compress,
              label: 'Pressure',
              value: '${weather.pressureHpa.toStringAsFixed(0)} hPa',
            ),
            _Metric(
              icon: Icons.eco_outlined,
              label: 'Air quality',
              value: _airQualityText(weather),
            ),
            _Metric(
              icon: Icons.local_florist_outlined,
              label: 'Pollen',
              value: weather.pollen == null || !weather.pollen!.hasAny
                  ? 'Unavailable'
                  : weather.pollen!.displayText,
            ),
            _Metric(
              icon: Icons.blur_on,
              label: 'PM2.5',
              value: weather.pm25 == null
                  ? 'Unavailable'
                  : '${weather.pm25!.toStringAsFixed(1)} \u00B5g/m\u00B3',
            ),
            _Metric(
              icon: Icons.grain,
              label: 'PM10',
              value: weather.pm10 == null
                  ? 'Unavailable'
                  : '${weather.pm10!.toStringAsFixed(1)} \u00B5g/m\u00B3',
            ),
            _Metric(
              icon: Icons.schedule,
              label: 'Updated',
              value: weather.lastUpdatedText,
            ),
          ],
        ),
        if (isRefreshing) ...<Widget>[
          const SizedBox(height: 12),
          const Text('Refreshing...'),
        ],
      ],
    );
  }

  String _airQualityText(WeatherModel weather) {
    if (weather.airQualityIndex == null || weather.airQualityLabel == null) {
      return 'Unavailable';
    }
    return '${weather.airQualityIndex} ${weather.airQualityLabel}';
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
