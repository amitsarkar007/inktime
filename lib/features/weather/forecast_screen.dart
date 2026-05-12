import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../shared/app_footer.dart';
import '../../shared/error_view.dart';
import 'weather_model.dart';
import 'weather_symbol.dart';

final DateFormat _dayFormatter = DateFormat('EEE d MMM');

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({
    required this.weather,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
    required this.isDarkMode,
    required this.onToggleDarkMode,
    super.key,
  });

  final WeatherModel? weather;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRefresh;
  final bool isDarkMode;
  final VoidCallback onToggleDarkMode;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        color: Theme.of(context).colorScheme.onSurface,
        backgroundColor: Theme.of(context).colorScheme.surface,
        onRefresh: onRefresh,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'InkTime',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    IconButton(
                      tooltip: isDarkMode ? 'Use light mode' : 'Use dark mode',
                      onPressed: onToggleDarkMode,
                      icon: Icon(
                        isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'FORECAST',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Refresh forecast',
                      onPressed: isLoading ? null : onRefresh,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (isLoading && weather == null)
                  const Text('Loading forecast...')
                else if (errorMessage != null && weather == null)
                  ErrorView(message: errorMessage!, onRetry: onRefresh)
                else if (weather != null) ...<Widget>[
                  _TodayPanel(forecasts: weather!.hourlyForecast),
                  const SizedBox(height: 24),
                  _FiveDayPanel(forecasts: weather!.dailyForecast),
                ],
                const SizedBox(height: 24),
                const AppFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TodayPanel extends StatelessWidget {
  const _TodayPanel({required this.forecasts});

  final List<HourlyForecast> forecasts;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'REST OF TODAY',
      child: forecasts.isEmpty
          ? Text(
              'No remaining hourly forecast for today.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: forecasts.map((HourlyForecast forecast) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _HourTile(forecast: forecast),
                  );
                }).toList(growable: false),
              ),
            ),
    );
  }
}

class _HourTile extends StatelessWidget {
  const _HourTile({required this.forecast});

  final HourlyForecast forecast;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = Theme.of(context).dividerTheme.color ?? Colors.transparent;

    return Container(
      width: 116,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(forecast.timeText, style: Theme.of(context).textTheme.bodyMedium),
              ),
              WeatherSymbol(code: forecast.weatherCode, size: 24),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${forecast.temperatureCelsius.toStringAsFixed(1)}\u00B0C',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            forecast.condition,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          _TinyMetric(
            icon: Icons.device_thermostat,
            value: '${forecast.feelsLikeCelsius.toStringAsFixed(1)}\u00B0C',
          ),
          const SizedBox(height: 6),
          _TinyMetric(
            icon: Icons.percent,
            value: '${forecast.precipitationProbabilityPercent}%',
          ),
          const SizedBox(height: 6),
          _TinyMetric(
            icon: Icons.air,
            value: '${forecast.windSpeedKmh.toStringAsFixed(0)} km/h',
          ),
        ],
      ),
    );
  }
}

class _FiveDayPanel extends StatelessWidget {
  const _FiveDayPanel({required this.forecasts});

  final List<DailyForecast> forecasts;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'NEXT 5 DAYS',
      child: forecasts.isEmpty
          ? Text(
              'Five day forecast is unavailable.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          : Column(
              children: forecasts.map((DailyForecast forecast) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _DayTile(forecast: forecast),
                );
              }).toList(growable: false),
            ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({required this.forecast});

  final DailyForecast forecast;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = Theme.of(context).dividerTheme.color ?? Colors.transparent;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              WeatherSymbol(code: forecast.weatherCode, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _dayFormatter.format(forecast.date),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(forecast.condition, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              Text(
                '${forecast.highCelsius.toStringAsFixed(1)}/${forecast.lowCelsius.toStringAsFixed(1)}\u00B0C',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: <Widget>[
              _TinyMetric(
                icon: Icons.percent,
                value: '${forecast.precipitationProbabilityPercent}%',
              ),
              _TinyMetric(
                icon: Icons.wb_sunny_outlined,
                value: forecast.uvIndexMax == null
                    ? 'UV unavailable'
                    : 'UV ${forecast.uvIndexMax!.toStringAsFixed(1)}',
              ),
              _TinyMetric(icon: Icons.wb_twilight, value: forecast.sunriseText),
              _TinyMetric(icon: Icons.nightlight_round, value: forecast.sunsetText),
            ],
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _TinyMetric extends StatelessWidget {
  const _TinyMetric({
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 15),
        const SizedBox(width: 5),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
