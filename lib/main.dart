import 'package:flutter/material.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz_data.initializeTimeZones();
  runApp(const InkTimeApp());
}
