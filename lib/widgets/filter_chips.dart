import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/donor.dart';
import '../providers/filter_provider.dart';
import '../theme.dart';

/// Compact, horizontally scrollable filters for the donor list.
class FilterBar extends StatelessWidget {
  final List<String> cities;

  const FilterBar({super.key, required this.cities});

  @override
  Widget build(BuildContext context) {
    final filter = context.watch<FilterProvider>();

    return Column(
      children: [
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _GroupChip(
                label: 'All',
                selected: filter.bloodGroup.isEmpty,
                onTap: () => filter.setBloodGroup(''),
              ),
              ...kBloodGroups.map(
                (group) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _GroupChip(
                    label: group,
                    selected: filter.bloodGroup == group,
                    onTap: () => filter.setBloodGroup(group),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _ToggleChip(
                label: 'Available now',
                icon: Icons.check_circle_outline,
                selected: filter.availableOnly,
                onTap: () =>
                    filter.setAvailableOnly(!filter.availableOnly),
              ),
              const SizedBox(width: 8),
              _ToggleChip(
                label: 'Favorites',
                icon: Icons.star_outline,
                selected: filter.favoritesOnly,
                onTap: () => filter.setFavoritesOnly(!filter.favoritesOnly),
              ),
              const SizedBox(width: 8),
              _SelectChip(
                label: 'City',
                value: filter.city,
                options: cities,
                onSelected: filter.setCity,
              ),
              const SizedBox(width: 8),
              _SelectChip(
                label: 'Compatible',
                value: filter.compatibleWith,
                options: kBloodGroups,
                onSelected: filter.setCompatibleWith,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GroupChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GroupChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.bloodRed.withValues(alpha: 0.12),
      labelStyle: TextStyle(
        fontSize: 13,
        color: selected ? AppTheme.darkRed : Colors.black87,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: selected
            ? AppTheme.bloodRed.withValues(alpha: 0.4)
            : Colors.grey.shade300,
      ),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      avatar: Icon(
        icon,
        size: 16,
        color: selected ? AppTheme.bloodRed : Colors.grey.shade600,
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.bloodRed.withValues(alpha: 0.12),
      checkmarkColor: AppTheme.bloodRed,
      labelStyle: TextStyle(
        fontSize: 12,
        color: selected ? AppTheme.darkRed : Colors.black87,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: selected
            ? AppTheme.bloodRed.withValues(alpha: 0.4)
            : Colors.grey.shade300,
      ),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _SelectChip extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onSelected;

  const _SelectChip({
    required this.label,
    required this.value,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final active = value.isNotEmpty;
    return PopupMenuButton<String>(
      tooltip: label,
      onSelected: onSelected,
      itemBuilder: (context) => [
        const PopupMenuItem(value: '', child: Text('Any')),
        ...options.map(
          (option) => PopupMenuItem(value: option, child: Text(option)),
        ),
      ],
      child: Chip(
        avatar: Icon(
          active ? Icons.filter_alt : Icons.expand_more,
          size: 16,
          color: active ? AppTheme.bloodRed : Colors.grey.shade600,
        ),
        label: Text(active ? '$label: $value' : label),
        labelStyle: TextStyle(
          fontSize: 12,
          color: active ? AppTheme.darkRed : Colors.black87,
          fontWeight: active ? FontWeight.w600 : FontWeight.normal,
        ),
        backgroundColor:
            active ? AppTheme.bloodRed.withValues(alpha: 0.08) : null,
        side: BorderSide(
          color: active
              ? AppTheme.bloodRed.withValues(alpha: 0.4)
              : Colors.grey.shade300,
        ),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
