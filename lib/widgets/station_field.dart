import 'package:flutter/material.dart';

import '../data/metro_data.dart';

/// A searchable dropdown for choosing a metro station.
class StationField extends StatelessWidget {
  const StationField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.options,
    this.onSelected,
    this.hintText,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final List<String>? options;
  final ValueChanged<String>? onSelected;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final stations = options ?? allStations;
    return DropdownMenu<String>(
      controller: controller,
      requestFocusOnTap: true,
      enableFilter: true,
      expandedInsets: EdgeInsets.zero,
      menuHeight: 320,
      label: Text(label),
      hintText: hintText ?? 'Search a station',
      leadingIcon: Icon(icon),
      textInputAction: TextInputAction.next,
      dropdownMenuEntries: [
        for (final station in stations)
          DropdownMenuEntry<String>(value: station, label: station),
      ],
      onSelected: (value) {
        if (value == null) return;
        controller.text = value;
        onSelected?.call(value);
      },
    );
  }
}
