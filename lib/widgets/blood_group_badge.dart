import 'package:flutter/material.dart';

import '../theme.dart';

class BloodGroupBadge extends StatelessWidget {
  final String bloodGroup;
  final double size;

  const BloodGroupBadge({
    super.key,
    required this.bloodGroup,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.bloodGroupColor(bloodGroup);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      alignment: Alignment.center,
      child: Text(
        bloodGroup,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.32,
        ),
      ),
    );
  }
}
