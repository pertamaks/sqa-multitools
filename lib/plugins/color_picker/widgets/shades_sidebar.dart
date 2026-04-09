import 'package:flutter/material.dart';

class ShadesSidebar extends StatelessWidget {
  final Color color;

  const ShadesSidebar({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    var hsl = HSLColor.fromColor(color);
    var shades = [
      hsl.withLightness((hsl.lightness + 0.3).clamp(0.0, 1.0)).toColor(),
      hsl.withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0)).toColor(),
      hsl.toColor(),
      hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor(),
      hsl.withLightness((hsl.lightness - 0.3).clamp(0.0, 1.0)).toColor(),
    ];

    return Container(
      width: 48,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: shades
              .map((shade) => Container(height: 48, color: shade))
              .toList(),
        ),
      ),
    );
  }
}
