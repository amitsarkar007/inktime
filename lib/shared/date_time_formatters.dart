import 'package:intl/intl.dart';

final DateFormat _timeFormatter = DateFormat('HH:mm');
final DateFormat _dateFormatter = DateFormat('EEEE, d MMMM yyyy');

String format24Hour(DateTime dateTime) {
  return _timeFormatter.format(dateTime);
}

String formatDate(DateTime dateTime) {
  return _dateFormatter.format(dateTime);
}

String localTimezoneName(DateTime dateTime) {
  return dateTime.timeZoneName;
}
