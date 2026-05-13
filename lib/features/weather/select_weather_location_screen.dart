import 'dart:async';

import 'package:flutter/material.dart';

import '../../shared/result.dart';
import '../timezones/timezone_model.dart';
import '../timezones/timezone_service.dart';
import 'weather_location_model.dart';

class SelectWeatherLocationScreen extends StatefulWidget {
  const SelectWeatherLocationScreen({
    required this.service,
    required this.currentLocationLabel,
    super.key,
  });

  final TimezoneService service;
  final String currentLocationLabel;

  @override
  State<SelectWeatherLocationScreen> createState() => _SelectWeatherLocationScreenState();
}

class _SelectWeatherLocationScreenState extends State<SelectWeatherLocationScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  bool _isLoading = false;
  String? _error;
  List<TimezoneModel> _results = const <TimezoneModel>[];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      unawaited(_search(query));
    });
  }

  Future<void> _search(String query) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final Result<List<TimezoneModel>> result = await widget.service.searchCities(query);
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = false;
      switch (result) {
        case Success<List<TimezoneModel>>(:final value):
          _results = value;
        case Failure<List<TimezoneModel>>(:final message):
          _error = message;
          _results = const <TimezoneModel>[];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather location')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(const UseGpsWeatherLocation()),
                icon: const Icon(Icons.my_location),
                label: Text('Use GPS location (${widget.currentLocationLabel})'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Search weather location',
                  prefixIcon: Icon(Icons.search),
                ),
                textInputAction: TextInputAction.search,
                onChanged: _onQueryChanged,
                onSubmitted: (String value) => unawaited(_search(value)),
              ),
              const SizedBox(height: 16),
              if (_isLoading) const Text('Searching...'),
              if (_error != null) Text(_error!),
              if (!_isLoading && _error == null && _controller.text.length >= 2 && _results.isEmpty)
                const Text('No matching locations.'),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (BuildContext context, int index) {
                    final TimezoneModel model = _results[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        title: Text(model.city),
                        subtitle: Text('${model.country}\n${model.timezone}'),
                        trailing: const Icon(Icons.cloud_outlined),
                        onTap: () {
                          Navigator.of(context).pop(
                            WeatherLocationModel.fromTimezone(model),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UseGpsWeatherLocation {
  const UseGpsWeatherLocation();
}
