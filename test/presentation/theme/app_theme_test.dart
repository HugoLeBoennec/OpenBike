import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:open_bike/core/domain/entities/power_zone.dart';
import 'package:open_bike/presentation/theme/app_theme.dart';

/// WCAG 2.x relative-luminance contrast ratio, matching
/// [Color.computeLuminance]'s definition.
double _contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('contrastingTextColor', () {
    test('picks black on light backgrounds', () {
      expect(contrastingTextColor(Colors.white), Colors.black);
      expect(contrastingTextColor(const Color(0xFFFFEB3B)), Colors.black);
    });

    test('picks white on dark backgrounds', () {
      expect(contrastingTextColor(Colors.black), Colors.white);
      expect(contrastingTextColor(const Color(0xFF9C27B0)), Colors.white);
    });

    test('meets WCAG AA (>=4.5:1) for every zone color in the palette', () {
      for (final color in PowerZone.zoneColorPalette) {
        final text = contrastingTextColor(color);
        final ratio = _contrastRatio(color, text);
        expect(ratio, greaterThanOrEqualTo(4.5),
            reason: 'zone color $color contrasts $ratio:1 against $text');
      }
    });
  });
}
