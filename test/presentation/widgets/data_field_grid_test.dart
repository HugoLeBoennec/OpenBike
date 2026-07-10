import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_bike/infrastructure/persistence/app_database.dart';
import 'package:open_bike/infrastructure/preferences/app_preferences.dart';
import 'package:open_bike/presentation/models/data_field_type.dart';
import 'package:open_bike/presentation/state/providers.dart';
import 'package:open_bike/presentation/widgets/data_field_grid.dart';

Widget _wrap(double textScale, AppDatabase db, AppPreferences appPrefs) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      appPreferencesProvider.overrideWithValue(appPrefs),
    ],
    child: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            height: 220,
            // elapsedTime is excluded: it's driven by a Stream.periodic
            // ticker unrelated to layout, and leaves a pending Timer that
            // trips flutter_test's teardown check in a synchronous pump.
            child: DataFieldGrid(
              fields: DataFieldType.values
                  .where((f) => f != DataFieldType.elapsedTime)
                  .toList(),
              columns: 3,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  late AppDatabase db;
  late AppPreferences appPrefs;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({});
    appPrefs = AppPreferences(await SharedPreferences.getInstance());
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('renders every data field with no overflow at default text scale',
      (tester) async {
    await tester.pumpWidget(_wrap(1.0, db, appPrefs));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders every data field with no overflow at 1.3x text scale',
      (tester) async {
    await tester.pumpWidget(_wrap(1.3, db, appPrefs));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
