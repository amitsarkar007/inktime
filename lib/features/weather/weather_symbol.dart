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

    return switch (code) {
      0 => Icon(Icons.wb_sunny_outlined, size: size, color: color),
      1 || 2 => _CompositeWeatherIcon(
          size: size,
          base: Icons.wb_sunny_outlined,
          badges: const <_WeatherBadge>[
            _WeatherBadge(Icons.cloud_outlined, Alignment.bottomRight, 0.68),
          ],
        ),
      3 => Icon(Icons.cloud_outlined, size: size, color: color),
      45 || 48 => _CompositeWeatherIcon(
          size: size,
          base: Icons.cloud_outlined,
          badges: const <_WeatherBadge>[
            _WeatherBadge(Icons.dehaze, Alignment.bottomRight, 0.72),
          ],
        ),
      51 || 53 || 55 => _CompositeWeatherIcon(
          size: size,
          base: Icons.cloud_outlined,
          badges: const <_WeatherBadge>[
            _WeatherBadge(Icons.grain, Alignment.bottomRight, 0.62),
          ],
        ),
      56 || 57 || 66 || 67 => _CompositeWeatherIcon(
          size: size,
          base: Icons.cloud_outlined,
          badges: const <_WeatherBadge>[
            _WeatherBadge(Icons.water_drop_outlined, Alignment.bottomLeft, 0.55),
            _WeatherBadge(Icons.ac_unit, Alignment.bottomRight, 0.58),
          ],
        ),
      61 || 63 || 65 => _CompositeWeatherIcon(
          size: size,
          base: Icons.cloud_outlined,
          badges: const <_WeatherBadge>[
            _WeatherBadge(Icons.water_drop_outlined, Alignment.bottomRight, 0.68),
          ],
        ),
      71 || 73 || 75 || 77 => _CompositeWeatherIcon(
          size: size,
          base: Icons.cloud_outlined,
          badges: const <_WeatherBadge>[
            _WeatherBadge(Icons.ac_unit, Alignment.bottomRight, 0.68),
          ],
        ),
      80 || 81 || 82 => _CompositeWeatherIcon(
          size: size,
          base: Icons.cloud_outlined,
          badges: const <_WeatherBadge>[
            _WeatherBadge(Icons.water_drop_outlined, Alignment.bottomLeft, 0.55),
            _WeatherBadge(Icons.water_drop, Alignment.bottomRight, 0.55),
          ],
        ),
      85 || 86 => _CompositeWeatherIcon(
          size: size,
          base: Icons.cloud_outlined,
          badges: const <_WeatherBadge>[
            _WeatherBadge(Icons.ac_unit, Alignment.bottomLeft, 0.56),
            _WeatherBadge(Icons.air, Alignment.bottomRight, 0.55),
          ],
        ),
      95 => _CompositeWeatherIcon(
          size: size,
          base: Icons.thunderstorm_outlined,
          badges: const <_WeatherBadge>[
            _WeatherBadge(Icons.flash_on, Alignment.bottomRight, 0.66),
          ],
        ),
      96 || 99 => _CompositeWeatherIcon(
          size: size,
          base: Icons.thunderstorm_outlined,
          badges: const <_WeatherBadge>[
            _WeatherBadge(Icons.flash_on, Alignment.bottomLeft, 0.58),
            _WeatherBadge(Icons.grain, Alignment.bottomRight, 0.58),
          ],
        ),
      _ => Icon(Icons.help_outline, size: size, color: color),
    };
  }
}

class _CompositeWeatherIcon extends StatelessWidget {
  const _CompositeWeatherIcon({
    required this.size,
    required this.base,
    required this.badges,
  });

  final double size;
  final IconData base;
  final List<_WeatherBadge> badges;

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.onSurface;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Icon(base, size: size, color: color),
          ),
          for (final _WeatherBadge badge in badges)
            Align(
              alignment: badge.alignment,
              child: Transform.translate(
                offset: Offset(size * 0.08, size * 0.08),
                child: Icon(
                  badge.icon,
                  size: size * badge.scale,
                  color: color,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WeatherBadge {
  const _WeatherBadge(this.icon, this.alignment, this.scale);

  final IconData icon;
  final Alignment alignment;
  final double scale;
}
