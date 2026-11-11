import 'package:flutter/material.dart';
import 'package:blood_donor_finder/theme.dart';

class BloodGroupFilterChips extends StatelessWidget {
  final List<String> bloodGroups;
  final String? selectedGroup;
  final ValueChanged<String?> onSelected;

  const BloodGroupFilterChips({
    super.key,
    required this.bloodGroups,
    required this.selectedGroup,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: bloodGroups.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return FilterChip(
              label: const Text('All'),
              selected: selectedGroup == null,
              onSelected: (_) => onSelected(null),
              backgroundColor: AppColors.chipBg,
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: selectedGroup == null ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            );
          }
          final group = bloodGroups[index - 1];
          final isSelected = selectedGroup == group;
          return FilterChip(
            label: Text(group),
            selected: isSelected,
            onSelected: (_) => onSelected(isSelected ? null : group),
            backgroundColor: AppColors.chipBg,
            selectedColor: AppColors.primary,
            checkmarkColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          );
        },
      ),
    );
  }
}
