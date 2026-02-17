import 'package:flutter/material.dart';

import '../models/data_field_type.dart';

/// Dialog allowing the user to pick which data field to display in a cell.
class FieldPickerDialog extends StatelessWidget {
  final DataFieldType currentType;
  final ValueChanged<DataFieldType> onSelected;

  const FieldPickerDialog({
    super.key,
    required this.currentType,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Select Field'),
      backgroundColor: const Color(0xFF222222),
      children: DataFieldType.values.map((type) {
        final isSelected = type == currentType;
        return SimpleDialogOption(
          onPressed: () {
            onSelected(type);
            Navigator.pop(context);
          },
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  type.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              Text(
                type.unit,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
