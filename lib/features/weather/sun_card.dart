import 'package:flutter/material.dart';

import 'weather_model.dart';

class SunCard extends StatelessWidget {
  const SunCard({
    required this.weather,
    super.key,
  });

  final WeatherModel weather;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'SUN',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            Expanded(
              child: _SunTime(
                icon: Icons.wb_sunny_outlined,
                label: 'Sunrise',
                value: weather.sunriseText,
              ),
            ),
            Expanded(
              child: _SunTime(
                icon: Icons.nightlight_round,
                label: 'Sunset',
                value: weather.sunsetText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Center(
          child: _SunTime(
            icon: Icons.timelapse,
            label: 'Daylight',
            value: weather.daylightDurationText,
          ),
        ),
      ],
    );
  }
}

class _SunTime extends StatelessWidget {
  const _SunTime({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(icon, size: 28),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
