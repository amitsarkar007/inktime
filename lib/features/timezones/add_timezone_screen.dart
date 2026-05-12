import 'dart:async';

import 'package:flutter/material.dart';

import '../../shared/result.dart';
import 'timezone_model.dart';
import 'timezone_service.dart';

class AddTimezoneScreen extends StatefulWidget {
  const AddTimezoneScreen({
    required this.service,
    super.key,
  });

  final TimezoneService service;

  @override
  State<AddTimezoneScreen> createState() => _AddTimezoneScreenState();
}

class _AddTimezoneScreenState extends State<AddTimezoneScreen> {
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
      appBar: AppBar(title: const Text('Add timezone')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: _controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Search city',
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
                const Text('No matching cities.'),
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
                        trailing: const Icon(Icons.add),
                        onTap: () => Navigator.of(context).pop(model),
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
