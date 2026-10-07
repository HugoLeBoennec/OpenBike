import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:open_bike/core/application/services/recording_engine.dart';
import 'package:open_bike/presentation/state/providers.dart';
import 'package:open_bike/presentation/widgets/ride_header_bar.dart';

Widget _wrap(double width) {
  return ProviderScope(
    overrides: [
      rideElapsedProvider
          .overrideWith((ref) => Stream.value(const Duration(minutes: 11, seconds: 41))),
      recordingStateProvider
          .overrideWith((ref) => Stream.value(RecordingState.recording)),
      roleConnectionProvider.overrideWithValue(const {}),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: width, child: const RideHeaderBar()),
        ),
      ),
    ),
  );
}

void main() {
  final timer = find.text('00:11:41');

  for (final width in [320.0, 360.0, 370.0, 617.0, 1200.0, 1440.0]) {
    testWidgets('timer stays on one line without overflow at $width dp',
        (tester) async {
      await tester.pumpWidget(_wrap(width));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(timer, findsOneWidget);

      // Rendered (scaled) extent: one line high and inside the header.
      final top = tester.getTopLeft(timer);
      final bottom = tester.getBottomRight(timer);
      expect(bottom.dy - top.dy, lessThan(56)); // header height; two lines would be ~80
      expect(bottom.dx, lessThanOrEqualTo(width));
    });
  }

  testWidgets('timer keeps its full size when there is room', (tester) async {
    await tester.pumpWidget(_wrap(1200));
    await tester.pump();

    final rendered = tester.getBottomRight(timer) - tester.getTopLeft(timer);
    final layout = tester.getSize(timer);
    expect(rendered.dx, closeTo(layout.width, 0.5));
    expect(rendered.dy, closeTo(layout.height, 0.5));
  });
}
