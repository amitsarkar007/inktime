import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geolocator/geolocator.dart';

import 'features/clock/clock_controller.dart';
import 'features/timezones/add_timezone_screen.dart';
import 'features/timezones/timezone_list.dart';
import 'features/timezones/timezone_model.dart';
import 'features/timezones/timezone_repository.dart';
import 'features/timezones/timezone_service.dart';
import 'features/weather/location_service.dart';
import 'features/weather/forecast_screen.dart';
import 'features/weather/select_weather_location_screen.dart';
import 'features/weather/sun_card.dart';
import 'features/weather/weather_card.dart';
import 'features/weather/weather_location_model.dart';
import 'features/weather/weather_location_repository.dart';
import 'features/weather/weather_model.dart';
import 'features/weather/weather_service.dart';
import 'shared/app_footer.dart';
import 'shared/date_time_formatters.dart';
import 'shared/eink_theme.dart';
import 'shared/result.dart';

class InkTimeApp extends StatefulWidget {
  const InkTimeApp({super.key});

  @override
  State<InkTimeApp> createState() => _InkTimeAppState();
}

class _InkTimeAppState extends State<InkTimeApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InkTime',
      debugShowCheckedModeBanner: false,
      theme: EInkTheme.data(isDark: _isDarkMode),
      home: DashboardScreen(
        isDarkMode: _isDarkMode,
        onToggleDarkMode: () {
          setState(() => _isDarkMode = !_isDarkMode);
        },
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    required this.isDarkMode,
    required this.onToggleDarkMode,
    super.key,
  });

  final bool isDarkMode;
  final VoidCallback onToggleDarkMode;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ClockController _clockController = ClockController();
  final LocationService _locationService = LocationService();
  final WeatherService _weatherService = WeatherService();
  final WeatherLocationRepository _weatherLocationRepository =
      WeatherLocationRepository();
  final TimezoneService _timezoneService = TimezoneService();
  final TimezoneRepository _timezoneRepository = TimezoneRepository();

  bool _weatherLoading = false;
  int _selectedIndex = 0;
  WeatherModel? _weather;
  String? _weatherError;
  String? _weatherLocationLabel;
  WeatherLocationModel? _selectedWeatherLocation;
  String _localTimezone = DateTime.now().timeZoneName;
  List<TimezoneModel> _savedTimezones = const <TimezoneModel>[];

  @override
  void initState() {
    super.initState();
    _clockController.start();
    unawaited(_loadLocalTimezone());
    unawaited(_loadSelectedWeatherLocation());
    unawaited(_loadSavedTimezones());
  }

  @override
  void dispose() {
    _clockController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalTimezone() async {
    try {
      final String timezone = await FlutterTimezone.getLocalTimezone();
      if (mounted) {
        setState(() => _localTimezone = timezone);
      }
    } on Exception {
      if (mounted) {
        setState(() => _localTimezone = DateTime.now().timeZoneName);
      }
    }
  }

  Future<void> _loadSavedTimezones() async {
    final List<TimezoneModel> saved = await _timezoneRepository.load();
    if (mounted) {
      setState(() => _savedTimezones = saved);
    }
  }

  Future<void> _loadSelectedWeatherLocation() async {
    final WeatherLocationModel? location = await _weatherLocationRepository.load();
    if (mounted) {
      setState(() => _selectedWeatherLocation = location);
      await _refreshWeather();
    }
  }

  Future<void> _refreshWeather() async {
    if (_weatherLoading) {
      return;
    }

    setState(() {
      _weatherLoading = true;
      _weatherError = null;
    });

    final WeatherLocationModel? selectedLocation = _selectedWeatherLocation;
    if (selectedLocation != null) {
      final Result<WeatherModel> weatherResult = await _weatherService.fetchWeather(
        latitude: selectedLocation.latitude,
        longitude: selectedLocation.longitude,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _weatherLoading = false;
        switch (weatherResult) {
          case Success<WeatherModel>(:final value):
            _weather = value;
            _weatherLocationLabel = selectedLocation.label;
            _weatherError = null;
          case Failure<WeatherModel>(:final message):
            _weatherError = message;
        }
      });
      return;
    }

    final Result<Position> locationResult = await _locationService.getOneShotPosition();
    if (!mounted) {
      return;
    }

    switch (locationResult) {
      case Success<Position>(:final value):
        final String? locationLabel = await _locationService.describePosition(value);
        final Result<WeatherModel> weatherResult = await _weatherService.fetchWeather(
          latitude: value.latitude,
          longitude: value.longitude,
        );
        if (!mounted) {
          return;
        }
        setState(() {
          _weatherLoading = false;
          switch (weatherResult) {
            case Success<WeatherModel>(:final value):
              _weather = value;
              _weatherLocationLabel = locationLabel;
              _weatherError = null;
            case Failure<WeatherModel>(:final message):
              _weatherError = message;
          }
        });
      case Failure<Position>(:final message):
        setState(() {
          _weatherLoading = false;
          _weatherError = message;
        });
    }
  }

  Future<void> _addTimezone() async {
    final TimezoneModel? selected = await Navigator.of(context).push<TimezoneModel>(
      MaterialPageRoute<TimezoneModel>(
        builder: (_) => AddTimezoneScreen(service: _timezoneService),
      ),
    );
    if (selected == null) {
      return;
    }

    final bool alreadySaved = _savedTimezones.any((TimezoneModel existing) {
      return existing.city == selected.city &&
          existing.country == selected.country &&
          existing.timezone == selected.timezone;
    });
    if (alreadySaved) {
      return;
    }

    final List<TimezoneModel> updated = <TimezoneModel>[
      ..._savedTimezones,
      selected,
    ];
    await _timezoneRepository.save(updated);
    if (mounted) {
      setState(() => _savedTimezones = updated);
    }
  }

  Future<void> _selectWeatherLocation() async {
    final Object? selected = await Navigator.of(context).push<Object>(
      MaterialPageRoute<Object>(
        builder: (_) => SelectWeatherLocationScreen(
          service: _timezoneService,
          isFollowingDevice: _selectedWeatherLocation == null,
          locationSummaryLine: _weatherLocationLabel ?? _localTimezone,
        ),
      ),
    );
    if (selected == null) {
      return;
    }

    if (selected is UseGpsWeatherLocation) {
      await _weatherLocationRepository.clear();
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedWeatherLocation = null;
        _weatherLocationLabel = null;
      });
      await _refreshWeather();
      return;
    }

    if (selected is WeatherLocationModel) {
      await _weatherLocationRepository.save(selected);
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedWeatherLocation = selected;
        _weatherLocationLabel = selected.label;
      });
      await _refreshWeather();
    }
  }

  Future<void> _removeTimezone(TimezoneModel model) async {
    final List<TimezoneModel> updated = _savedTimezones.where((TimezoneModel existing) {
      return !(existing.city == model.city &&
          existing.country == model.country &&
          existing.latitude == model.latitude &&
          existing.longitude == model.longitude &&
          existing.timezone == model.timezone);
    }).toList(growable: false);
    await _timezoneRepository.save(updated);
    if (mounted) {
      setState(() => _savedTimezones = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _clockController,
      builder: (BuildContext context, _) {
        final DateTime now = _clockController.now;
        final DateTime utcNow = now.toUtc();
        final List<TimezoneModel> sortedTimezones = _timezoneService.sortByCurrentLocalTime(
          _savedTimezones,
          utcNow,
        );

        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: <Widget>[
              SafeArea(
                child: RefreshIndicator(
                  color: Theme.of(context).colorScheme.onSurface,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  onRefresh: _refreshWeather,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                        children: <Widget>[
                          _Header(
                            isDarkMode: widget.isDarkMode,
                            onToggleDarkMode: widget.onToggleDarkMode,
                          ),
                          const SizedBox(height: 32),
                          _TimeSummary(
                            now: now,
                            localTimezone: _localTimezone,
                            locationLabel: _weatherLocationLabel,
                            isGpsLocation: _selectedWeatherLocation == null,
                            onChangeLocation: _selectWeatherLocation,
                          ),
                          const _SectionDivider(),
                          WeatherCard(
                            weather: _weather,
                            isLoading: _weatherLoading,
                            errorMessage: _weatherError,
                            onRefresh: _refreshWeather,
                          ),
                          if (_weather != null) ...<Widget>[
                            const _SectionDivider(),
                            SunCard(weather: _weather!),
                          ],
                          const _SectionDivider(),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  'WORLD CLOCK',
                                  style: Theme.of(context).textTheme.headlineMedium,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _addTimezone,
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Add timezone'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TimezoneList(
                            timezones: sortedTimezones,
                            utcNow: utcNow,
                            service: _timezoneService,
                            onDelete: (TimezoneModel model) =>
                                unawaited(_removeTimezone(model)),
                          ),
                          const SizedBox(height: 24),
                          const AppFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              ForecastScreen(
                weather: _weather,
                isLoading: _weatherLoading,
                errorMessage: _weatherError,
                onRefresh: _refreshWeather,
                isDarkMode: widget.isDarkMode,
                onToggleDarkMode: widget.onToggleDarkMode,
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() => _selectedIndex = index);
            },
            destinations: const <NavigationDestination>[
              NavigationDestination(
                icon: Icon(Icons.access_time),
                label: 'Now',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                label: 'Forecast',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.isDarkMode,
    required this.onToggleDarkMode,
  });

  final bool isDarkMode;
  final VoidCallback onToggleDarkMode;

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

class _TimeSummary extends StatelessWidget {
  const _TimeSummary({
    required this.now,
    required this.localTimezone,
    required this.locationLabel,
    required this.isGpsLocation,
    required this.onChangeLocation,
  });

  final DateTime now;
  final String localTimezone;
  final String? locationLabel;
  final bool isGpsLocation;
  final VoidCallback onChangeLocation;

  @override
  Widget build(BuildContext context) {
    final String locationText = locationLabel ?? localTimezone;

    return Center(
      child: Column(
        children: <Widget>[
          Text(
            format24Hour(now),
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 10),
          Text(
            formatDate(now),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  isGpsLocation ? '$locationText (GPS)' : locationText,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: onChangeLocation,
            icon: const Icon(Icons.search, size: 18),
            label: const Text('Change weather location'),
          ),
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Divider(height: 1),
    );
  }
}
