import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/presentation/models/data_field_type.dart';
import 'package:open_bike/presentation/state/providers.dart';
import 'package:open_bike/presentation/widgets/data_field_cell.dart';

Widget _wrap({List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(
      home: Scaffold(body: DataFieldCell(fieldType: DataFieldType.power)),
    ),
  );
}

void main() {
  testWidgets('exposes label, value, and unit as a single Semantics label',
      (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(_wrap(overrides: [
      livePowerProvider.overrideWith((ref) => const Watts(215)),
    ]));
    await tester.pump();

    final finder = find.bySemanticsLabel('POWER: 215 w');
    expect(finder, findsOneWidget);
    expect(tester.takeException(), isNull);

    handle.dispose();
  });

  testWidgets('renders without overflow at 1.3x text scale', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: _wrap(),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
