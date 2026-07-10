import 'package:flutter/material.dart';

import '../models/data_field_type.dart';
import '../theme/app_theme.dart';

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
    final tokens = context.tokens;
    return SimpleDialog(
      title: const Text('Select Field'),
      backgroundColor: tokens.surfaceTier2,
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
                    ? Icon(Icons.check, size: 16, color: tokens.textPrimary)
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  type.label,
                  style: TextStyle(
                    color: isSelected
                        ? tokens.textPrimary
                        : tokens.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              Text(
                type.unit,
                style: TextStyle(color: tokens.textTertiary, fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
