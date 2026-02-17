import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/data_field_type.dart';
import '../state/providers.dart';
import 'data_field_cell.dart';
import 'field_picker_dialog.dart';

/// Configurable grid of data field cells. Supports long-press to change fields.
class DataFieldGrid extends ConsumerWidget {
  final List<DataFieldType> fields;
  final int columns;
  final int pageIndex;

  const DataFieldGrid({
    super.key,
    required this.fields,
    this.columns = 2,
    this.pageIndex = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: 1.8,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
      ),
      itemCount: fields.length,
      itemBuilder: (context, index) {
        final fieldType = fields[index];
        return GestureDetector(
          onLongPress: () => _showFieldPicker(context, ref, index, fieldType),
          child: DataFieldCell(fieldType: fieldType),
        );
      },
    );
  }

  void _showFieldPicker(
    BuildContext context,
    WidgetRef ref,
    int fieldIndex,
    DataFieldType currentType,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => FieldPickerDialog(
        currentType: currentType,
        onSelected: (newType) {
          ref
              .read(rideScreenConfigProvider.notifier)
              .setFieldAt(pageIndex, fieldIndex, newType);
        },
      ),
    );
  }
}
