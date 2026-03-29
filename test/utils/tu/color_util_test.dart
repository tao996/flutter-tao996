import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tao996/src/utils/tu/color_util.dart';

void main() {
  group('ColorUtil', () {
    late ColorUtil colorUtil;

    setUp(() {
      colorUtil = const ColorUtil();
    });

    group('isFullyTransparent', () {
      test('returns true for transparent color', () {
        expect(colorUtil.isFullyTransparent(Colors.transparent), isTrue);
      });

      test('returns false for opaque color', () {
        expect(colorUtil.isFullyTransparent(Colors.red), isFalse);
      });

      test('returns false for semi-transparent color', () {
        expect(colorUtil.isFullyTransparent(Colors.red.withAlpha(128)), isFalse);
      });
    });

    group('isTransparent', () {
      test('returns true for fully transparent', () {
        expect(colorUtil.isTransparent(Colors.transparent), isTrue);
      });

      test('returns true for semi-transparent', () {
        expect(colorUtil.isTransparent(Colors.red.withAlpha(128)), isTrue);
      });

      test('returns false for opaque color', () {
        expect(colorUtil.isTransparent(Colors.red), isFalse);
      });
    });

    group('buildCheckerboard', () {
      test('creates CustomPaint widget', () {
        final widget = colorUtil.buildCheckerboard();
        expect(widget, isA<CustomPaint>());
      });

      test('creates with custom size', () {
        final widget = colorUtil.buildCheckerboard(squareSize: 16);
        expect(widget, isA<CustomPaint>());
      });
    });

    group('hexToColor', () {
      test('converts hex with hash', () {
        final color = colorUtil.hexToColor('#FF0000');
        expect(color.r, closeTo(1.0, 0.01));
        expect(color.g, closeTo(0.0, 0.01));
        expect(color.b, closeTo(0.0, 0.01));
      });

      test('converts hex without hash', () {
        final color = colorUtil.hexToColor('00FF00');
        expect(color.r, closeTo(0.0, 0.01));
        expect(color.g, closeTo(1.0, 0.01));
        expect(color.b, closeTo(0.0, 0.01));
      });

      test('handles short hex', () {
        final color = colorUtil.hexToColor('#F0F');
        expect(color.a, equals(1.0));
      });

      test('handles custom opacity', () {
        final color = colorUtil.hexToColor('#FF0000', opacity: 0.5);
        expect(color.a, closeTo(0.5, 0.01));
      });

      test('handles zero opacity', () {
        final color = colorUtil.hexToColor('#FF0000', opacity: 0.0);
        expect(color.a, equals(0.0));
      });
    });

    group('rgbToColor', () {
      test('converts RGB string', () {
        final color = colorUtil.rgbToColor('255, 0, 0');
        expect(color.r, closeTo(1.0, 0.01));
        expect(color.g, closeTo(0.0, 0.01));
        expect(color.b, closeTo(0.0, 0.01));
      });

      test('converts RGB without spaces', () {
        final color = colorUtil.rgbToColor('0,255,0');
        expect(color.r, closeTo(0.0, 0.01));
        expect(color.g, closeTo(1.0, 0.01));
        expect(color.b, closeTo(0.0, 0.01));
      });

      test('handles custom opacity', () {
        final color = colorUtil.rgbToColor('255, 0, 0', opacity: 0.5);
        expect(color.a, closeTo(0.5, 0.01));
      });

      test('returns black for invalid format', () {
        final color = colorUtil.rgbToColor('invalid');
        expect(color, equals(Colors.black));
      });

      test('returns black for wrong part count', () {
        final color = colorUtil.rgbToColor('255, 0');
        expect(color, equals(Colors.black));
      });
    });

    group('parseToColor', () {
      test('parses hex color', () {
        final color = colorUtil.parseToColor('#FF0000');
        expect(color.r, closeTo(1.0, 0.01));
      });

      test('parses RGB color', () {
        final color = colorUtil.parseToColor('0, 255, 0');
        expect(color.g, closeTo(1.0, 0.01));
      });

      test('returns transparent for invalid input', () {
        final color = colorUtil.parseToColor('invalid');
        expect(color, equals(Colors.transparent));
      });

      test('returns transparent for empty string', () {
        final color = colorUtil.parseToColor('');
        expect(color, equals(Colors.transparent));
      });

      test('handles custom opacity', () {
        final color = colorUtil.parseToColor('#FF0000', opacity: 0.5);
        expect(color.a, closeTo(0.5, 0.01));
      });
    });

    group('withOpacity', () {
      test('converts opacity to alpha', () {
        expect(colorUtil.withOpacity(1.0), equals(255));
        expect(colorUtil.withOpacity(0.5), equals(127));
        expect(colorUtil.withOpacity(0.0), equals(0));
      });

      test('handles null opacity', () {
        expect(colorUtil.withOpacity(null), equals(255));
      });

      test('handles values > 1', () {
        expect(colorUtil.withOpacity(1.5), equals(382)); // 1.5 * 255 = 382.5
      });

      test('handles negative values', () {
        expect(colorUtil.withOpacity(-0.5), equals(-127));
      });
    });

    // Note: color methods (success, error, danger, info, warning, text) require
    // Flutter binding initialization and Get context. These are integration tests.
    // group('color methods', () { ... });
  });

  group('CheckerboardPainter', () {
    test('can be instantiated', () {
      final painter = CheckerboardPainter();
      expect(painter, isNotNull);
    });

    test('can be instantiated with custom size', () {
      final painter = CheckerboardPainter(squareSize: 16);
      expect(painter, isNotNull);
    });
  });
}
