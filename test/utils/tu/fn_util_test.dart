import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tao996/src/utils/tu/fn_util.dart';

void main() {
  group('FnUtil', () {
    late FnUtil fnUtil;

    setUp(() {
      fnUtil = const FnUtil();
    });

    group('debounce', () {
      test('executes callback after delay', () async {
        var executed = false;
        fnUtil.debounce(() => executed = true, milliseconds: 50);

        expect(executed, isFalse);
        await Future.delayed(const Duration(milliseconds: 100));
        expect(executed, isTrue);
      });

      test('cancels previous call', () async {
        var counter = 0;
        fnUtil.debounce(() => counter++, milliseconds: 100);
        fnUtil.debounce(() => counter++, milliseconds: 100);
        fnUtil.debounce(() => counter++, milliseconds: 100);

        await Future.delayed(const Duration(milliseconds: 150));
        expect(counter, equals(1));
      });

      test('uses default delay when not specified', () async {
        var executed = false;
        fnUtil.debounce(() => executed = true);

        expect(executed, isFalse);
        await Future.delayed(const Duration(milliseconds: 600));
        expect(executed, isTrue);
      });
    });

    group('startTimeout', () {
      test('executes callback after timeout', () async {
        var executed = false;
        fnUtil.startTimeout(const Duration(milliseconds: 50), () {
          executed = true;
        });

        expect(executed, isFalse);
        await Future.delayed(const Duration(milliseconds: 100));
        expect(executed, isTrue);
      });

      test('can be cancelled', () async {
        var executed = false;
        final cancel = fnUtil.startTimeout(const Duration(milliseconds: 50), () {
          executed = true;
        });

        cancel();
        await Future.delayed(const Duration(milliseconds: 100));
        expect(executed, isFalse);
      });

      test('returns cancel function', () {
        final cancel = fnUtil.startTimeout(const Duration(seconds: 1), () {});
        expect(cancel, isA<VoidCallback>());
      });
    });

    group('randomDelay', () {
      test('delays for random duration', () async {
        final stopwatch = Stopwatch()..start();
        await fnUtil.randomDelay(minMilliseconds: 50, maxMilliseconds: 100);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(50));
        expect(stopwatch.elapsedMilliseconds, lessThan(150)); // Allow some tolerance
      });

      test('delays at least minMilliseconds', () async {
        final stopwatch = Stopwatch()..start();
        await fnUtil.randomDelay(minMilliseconds: 100, maxMilliseconds: 200);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(100));
      });

      test('delays at most maxMilliseconds', () async {
        // Run multiple times to reduce chance of false positive
        for (var i = 0; i < 5; i++) {
          final stopwatch = Stopwatch()..start();
          await fnUtil.randomDelay(minMilliseconds: 10, maxMilliseconds: 50);
          stopwatch.stop();

          expect(stopwatch.elapsedMilliseconds, lessThan(100)); // With tolerance
        }
      });

      test('uses default range when not specified', () async {
        final stopwatch = Stopwatch()..start();
        await fnUtil.randomDelay();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(500));
      });
    });

    group('delayed', () {
      test('delays for specified seconds', () async {
        final stopwatch = Stopwatch()..start();
        await fnUtil.delayed(seconds: 1);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(1000));
      });

      test('delays for specified milliseconds', () async {
        final stopwatch = Stopwatch()..start();
        await fnUtil.delayed(milliseconds: 100);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(100));
      });

      test('combines seconds and milliseconds', () async {
        final stopwatch = Stopwatch()..start();
        await fnUtil.delayed(seconds: 1, milliseconds: 100);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(1100));
      });

      test('uses default delay when no parameters', () async {
        final stopwatch = Stopwatch()..start();
        await fnUtil.delayed();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(1000));
      });

      test('delays for 1 second with zero values', () async {
        final stopwatch = Stopwatch()..start();
        await fnUtil.delayed(seconds: 0, milliseconds: 0);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(1000));
      });
    });
  });
}
