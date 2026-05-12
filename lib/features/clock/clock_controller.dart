import 'dart:async';

import 'package:flutter/foundation.dart';

class ClockController extends ChangeNotifier {
  ClockController({DateTime? initialTime}) : _now = initialTime ?? DateTime.now();

  Timer? _timer;
  DateTime _now;

  DateTime get now => _now;

  void start() {
    _updateToCurrentMinute();
    _timer?.cancel();
    final int secondsUntilNextMinute = 60 - DateTime.now().second;
    _timer = Timer(Duration(seconds: secondsUntilNextMinute), () {
      _updateToCurrentMinute();
      _timer = Timer.periodic(const Duration(minutes: 1), (_) {
        _updateToCurrentMinute();
      });
    });
  }

  void _updateToCurrentMinute() {
    final DateTime current = DateTime.now();
    _now = DateTime(
      current.year,
      current.month,
      current.day,
      current.hour,
      current.minute,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
