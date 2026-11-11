import 'package:flutter/material.dart';
import '../theme.dart';

class BloodDropBadge extends StatelessWidget {
  final String bloodGroup;
  final double size;

  const BloodDropBadge({super.key, required this.bloodGroup, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.bloodGroupColor(bloodGroup);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.water_drop,
        color: color,
        size: size * 0.55,
      ),
    );
  }
}
