import 'package:flutter_test/flutter_test.dart';
import 'package:tao996/src/utils/stack_util.dart';

void main() {
  group('StackUtil', () {
    group('debugPackages', () {
      test('contains package:tao996 by default', () {
        expect(StackUtil.debugPackages, contains('package:tao996'));
      });
    });

    group('inPackageLine', () {
      test('returns true for lines containing package:tao996', () {
        expect(
          StackUtil.inPackageLine('#0 package:tao996/src/model.dart:10:5'),
          isTrue,
        );
      });

      test('returns false for lines containing debug_service.dart', () {
        expect(
          StackUtil.inPackageLine('#0 package:tao996/src/debug_service.dart:10:5'),
          isFalse,
        );
      });

      test('returns false for lines containing log_service.dart', () {
        expect(
          StackUtil.inPackageLine('#0 package:tao996/src/log_service.dart:10:5'),
          isFalse,
        );
      });

      test('returns false for lines containing stack_util.dart', () {
        expect(
          StackUtil.inPackageLine('#0 package:tao996/src/stack_util.dart:10:5'),
          isFalse,
        );
      });

      test('returns false for lines not in debugPackages', () {
        expect(
          StackUtil.inPackageLine('#0 package:other_package/file.dart:10:5'),
          isFalse,
        );
      });
    });

    group('logPackages', () {
      test('adds packages with package: prefix', () {
        final initialCount = StackUtil.debugPackages.length;
        StackUtil.logPackages(['test_package']);
        expect(StackUtil.debugPackages.length, equals(initialCount + 1));
        expect(StackUtil.debugPackages, contains('package:test_package'));
      });

      test('does not add duplicate packages', () {
        StackUtil.logPackages(['unique_package']);
        final countAfterFirst = StackUtil.debugPackages.length;
        StackUtil.logPackages(['unique_package']);
        expect(StackUtil.debugPackages.length, equals(countAfterFirst));
      });

      test('accepts packages with existing package: prefix', () {
        StackUtil.logPackages(['package:prefixed_package']);
        expect(StackUtil.debugPackages, contains('package:prefixed_package'));
      });

      test('replaces all packages when append is false', () {
        StackUtil.logPackages(['package:package1', 'package:package2'], append: false);
        expect(StackUtil.debugPackages, equals(['package:package1', 'package:package2']));
      });

      test('does nothing when empty list provided', () {
        final countBefore = StackUtil.debugPackages.length;
        StackUtil.logPackages([]);
        expect(StackUtil.debugPackages.length, equals(countBefore));
      });

      test('can add multiple packages at once', () {
        final initialCount = StackUtil.debugPackages.length;
        StackUtil.logPackages(['pkg1', 'pkg2', 'pkg3']);
        expect(StackUtil.debugPackages.length, equals(initialCount + 3));
      });
    });

    group('getStackTraceString', () {
      test('returns list of strings', () {
        final result = StackUtil.getStackTraceString();
        expect(result, isA<List<String>>());
        expect(result.isNotEmpty, isTrue);
      });

      test('returns non-empty list', () {
        final result = StackUtil.getStackTraceString();
        expect(result.length, greaterThan(0));
      });

      test('contains stack trace information', () {
        final result = StackUtil.getStackTraceString();
        // First line should contain the test method
        expect(result[0], contains('getStackTraceString'));
      });
    });

    group('output', () {
      test('does not throw when called', () {
        expect(() {
          StackUtil.output(color: 'red');
        }, returnsNormally);
      });

      test('does not throw with filterNames', () {
        expect(() {
          StackUtil.output(color: 'blue', filterNames: ['test']);
        }, returnsNormally);
      });

      test('does not throw with first=true', () {
        expect(() {
          StackUtil.output(color: 'green', first: true);
        }, returnsNormally);
      });
    });
  });
}
