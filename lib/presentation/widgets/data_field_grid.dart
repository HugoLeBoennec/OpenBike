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

  /// Stretch the rows to fill the available height instead of using the
  /// fixed cell shape — for tall panes (portrait tablets) where fixed-ratio
  /// cells would fill only the top of the space.
  final bool fillHeight;

  const DataFieldGrid({
    super.key,
    required this.fields,
    this.columns = 2,
    this.pageIndex = 0,
    this.fillHeight = false,
  });

  static const _spacing = 1.0;
  static const _fixedAspectRatio = 1.8;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!fillHeight) return _grid(ref, _fixedAspectRatio);

    return LayoutBuilder(
      builder: (context, constraints) {
        final rows = (fields.length / columns).ceil();
        if (rows == 0 || !constraints.hasBoundedHeight) {
          return _grid(ref, _fixedAspectRatio);
        }
        final cellWidth =
            (constraints.maxWidth - _spacing * (columns - 1)) / columns;
        final cellHeight =
            (constraints.maxHeight - _spacing * (rows - 1)) / rows;
        return _grid(ref, cellWidth / cellHeight);
      },
    );
  }

  Widget _grid(WidgetRef ref, double aspectRatio) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: aspectRatio,
        mainAxisSpacing: _spacing,
        crossAxisSpacing: _spacing,
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
