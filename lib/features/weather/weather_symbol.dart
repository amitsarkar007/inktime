import 'package:flutter/material.dart';

class WeatherSymbol extends StatelessWidget {
  const WeatherSymbol({
    required this.code,
    this.size = 28,
    super.key,
  });

  final int code;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.onSurface;
    final double small = size * 0.58;

    if (code == 0) {
      return Icon(Icons.wb_sunny_outlined, size: size, color: color);
    }
    if (code == 1 || code == 2) {
      return _StackedWeatherIcon(
        size: size,
        back: Icon(Icons.wb_sunny_outlined, size: size, color: color),
        front: Icon(Icons.cloud_outlined, size: small, color: color),
      );
    }
    if (code == 3) {
      return Icon(Icons.cloud_outlined, size: size, color: color);
    }
    if (code == 45 || code == 48) {
      return _StackedWeatherIcon(
        size: size,
        back: Icon(Icons.cloud_outlined, size: size, color: color),
        front: Icon(Icons.dehaze, size: small, color: color),
      );
    }
    if (<int>{51, 53, 55, 56, 57}.contains(code)) {
      return _StackedWeatherIcon(
        size: size,
        back: Icon(Icons.cloud_outlined, size: size, color: color),
        front: Icon(Icons.grain, size: small, color: color),
      );
    }
    if (<int>{61, 63, 65, 66, 67, 80, 81, 82}.contains(code)) {
      return _StackedWeatherIcon(
        size: size,
        back: Icon(Icons.cloud_outlined, size: size, color: color),
        front: Icon(Icons.water_drop_outlined, size: small, color: color),
      );
    }
    if (<int>{71, 73, 75, 77, 85, 86}.contains(code)) {
      return _StackedWeatherIcon(
        size: size,
        back: Icon(Icons.cloud_outlined, size: size, color: color),
        front: Icon(Icons.ac_unit, size: small, color: color),
      );
    }
    if (<int>{95, 96, 99}.contains(code)) {
      return _StackedWeatherIcon(
        size: size,
        back: Icon(Icons.thunderstorm_outlined, size: size, color: color),
        front: Icon(Icons.flash_on, size: small, color: color),
      );
    }
    return Icon(Icons.help_outline, size: size, color: color);
  }
}

class _StackedWeatherIcon extends StatelessWidget {
  const _StackedWeatherIcon({
    required this.size,
    required this.back,
    required this.front,
  });

  final double size;
  final Widget back;
  final Widget front;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(left: 0, top: 0, child: back),
          Positioned(right: -2, bottom: -2, child: front),
        ],
      ),
    );
  }
}
