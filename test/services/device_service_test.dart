import 'package:flutter_test/flutter_test.dart';
import 'package:tao996/src/services/device_service.dart';

void main() {
  group('MyDeviceService', () {
    group('platform', () {
      test('returns non-empty string', () {
        final result = MyDeviceService.platform();
        expect(result, isNotEmpty);
        expect(result, isA<String>());
      });

      test('returns lowercase string', () {
        final result = MyDeviceService.platform();
        expect(result, equals(result.toLowerCase()));
      });

      test('contains platform identifier', () {
        final result = MyDeviceService.platform();
        // Should contain one of the platform identifiers
        final expectedPlatforms = [
          'android',
          'ios',
          'windows',
          'linux',
          'macos',
          'fuchsia',
        ];
        final hasMatch = expectedPlatforms.any((p) => result.contains(p));
        expect(
          hasMatch,
          isTrue,
          reason: 'Expected one of $expectedPlatforms but got $result',
        );
      });
    });

    group('isPc', () {
      test('returns boolean', () {
        expect(MyDeviceService.isPc(), isA<bool>());
      });

      test('returns true on desktop platforms', () {
        // Note: This test behavior depends on the platform running the test
        final isPc = MyDeviceService.isPc();
        final platform = MyDeviceService.platform();

        if (platform.contains('windows') ||
            platform.contains('linux') ||
            platform.contains('macos')) {
          expect(isPc, isTrue);
        }
      });
    });

    group('isMobile', () {
      test('returns boolean', () {
        expect(MyDeviceService.isMobile(), isA<bool>());
      });

      test('isMobile returns opposite of isPc', () {
        expect(MyDeviceService.isMobile(), equals(!MyDeviceService.isPc()));
      });
    });

    group('runtimeOS', () {
      test('returns OS enum', () {
        final result = MyDeviceService.runtimeOS();
        expect(result, isA<OS>());
      });

      test('returns non-unknown OS on supported platforms', () {
        final os = MyDeviceService.runtimeOS();
        // On testable platforms, should return specific OS
        expect(os, isNot(equals(OS.unknown)));
      });

      test('runtimeOS matches isPc and isMobile', () {
        final os = MyDeviceService.runtimeOS();
        final isPc = MyDeviceService.isPc();
        final isMobile = MyDeviceService.isMobile();

        if (os == OS.windows || os == OS.linux || os == OS.macos) {
          expect(isPc, isTrue);
          expect(isMobile, isFalse);
        } else if (os == OS.android || os == OS.ios) {
          expect(isPc, isFalse);
          expect(isMobile, isTrue);
        }
      });
    });

    group('OS enum', () {
      test('has all expected values', () {
        expect(OS.values.length, equals(8));
        expect(OS.values, contains(OS.unknown));
        expect(OS.values, contains(OS.windows));
        expect(OS.values, contains(OS.linux));
        expect(OS.values, contains(OS.unix));
        expect(OS.values, contains(OS.macos));
        expect(OS.values, contains(OS.android));
        expect(OS.values, contains(OS.ios));
        expect(OS.values, contains(OS.fuchsia));
      });

      test('enum values have correct indices', () {
        expect(OS.unknown.index, equals(0));
        expect(OS.windows.index, equals(1));
        expect(OS.linux.index, equals(2));
        expect(OS.unix.index, equals(3));
        expect(OS.macos.index, equals(4));
        expect(OS.android.index, equals(5));
        expect(OS.ios.index, equals(6));
        expect(OS.fuchsia.index, equals(7));
      });
    });

    group('screen size properties', () {
      test('initial screen dimensions are zero', () {
        expect(MyDeviceService.screenWidth, equals(0));
        expect(MyDeviceService.screenHeight, equals(0));
        expect(MyDeviceService.statusBarHeight, equals(0));
      });

      // Note: calScreenSize requires a BuildContext, which is not available in unit tests
      // This would need widget tests or integration tests
    });
  });
}
