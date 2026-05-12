import 'package:flutter/material.dart';

import '../../shared/date_time_formatters.dart';
import 'timezone_model.dart';
import 'timezone_service.dart';

class TimezoneList extends StatelessWidget {
  const TimezoneList({
    required this.timezones,
    required this.utcNow,
    required this.service,
    required this.onDelete,
    super.key,
  });

  final List<TimezoneModel> timezones;
  final DateTime utcNow;
  final TimezoneService service;
  final ValueChanged<TimezoneModel> onDelete;

  @override
  Widget build(BuildContext context) {
    if (timezones.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          'No saved timezones.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return Column(
      children: timezones.map((TimezoneModel model) {
        final DateTime localTime = service.timeInTimezone(model, utcNow);
        final bool isLast = model == timezones.last;
        final Color dividerColor = Theme.of(context).dividerTheme.color ?? Colors.transparent;
        final String dayLabel = _dayLabel(localTime, DateTime.now());
        return Dismissible(
          key: ValueKey<String>(
            '${model.city}-${model.country}-${model.latitude}-${model.longitude}',
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onDelete(model),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isLast ? Colors.transparent : dividerColor,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          model.city,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(model.country, style: Theme.of(context).textTheme.bodyMedium),
                        Text(model.timezone, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        format24Hour(localTime),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(dayLabel, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Delete ${model.city}',
                    onPressed: () => onDelete(model),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(growable: false),
    );
  }

  String _dayLabel(DateTime locationTime, DateTime localNow) {
    final DateTime locationDate = DateTime(
      locationTime.year,
      locationTime.month,
      locationTime.day,
    );
    final DateTime localDate = DateTime(
      localNow.year,
      localNow.month,
      localNow.day,
    );
    final int difference = locationDate.difference(localDate).inDays;
    if (difference == 0) {
      return 'Today';
    }
    if (difference == 1) {
      return 'Tomorrow';
    }
    if (difference == -1) {
      return 'Yesterday';
    }
    return difference > 0 ? '+$difference days' : '$difference days';
  }
}
