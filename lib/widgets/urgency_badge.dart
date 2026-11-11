import 'package:flutter/material.dart';

import '../models/blood_request.dart';

Color urgencyColor(RequestUrgency urgency) {
  switch (urgency) {
    case RequestUrgency.normal:
      return Colors.blueGrey;
    case RequestUrgency.urgent:
      return Colors.orange.shade800;
    case RequestUrgency.critical:
      return Colors.red.shade700;
  }
}

class UrgencyBadge extends StatelessWidget {
  final RequestUrgency urgency;

  const UrgencyBadge({super.key, required this.urgency});

  @override
  Widget build(BuildContext context) {
    final color = urgencyColor(urgency);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (urgency != RequestUrgency.normal) ...[
            Icon(Icons.priority_high, size: 12, color: color),
            const SizedBox(width: 2),
          ],
          Text(
            urgency.label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
