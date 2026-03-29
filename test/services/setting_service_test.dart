import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tao996/src/services/setting_service.dart';

// 创建一个具体的测试实现类
class TestSettingService extends SettingService {
  @override
  String get serverHost => prefs.getString('serverHost') ?? '';
}

void main() {
  group('SettingService', () {
    late TestSettingService settingService;

    setUp(() async {
      // 初始化 SharedPreferences 的 mock
      SharedPreferences.setMockInitialValues({});
      await initSharedPreferences();
      settingService = TestSettingService();
    });

    group('language', () {
      test('defaults to "system"', () {
        expect(settingService.language, equals('system'));
      });

      test('can be set and retrieved', () {
        settingService.language = 'zh_CN';
        expect(settingService.language, equals('zh_CN'));
      });

      test('persists value', () {
        settingService.language = 'en_US';
        // Create new instance to verify persistence
        final newService = TestSettingService();
        expect(newService.language, equals('en_US'));
      });
    });

    group('themeMode', () {
      test('defaults to 0', () {
        expect(settingService.themeMode, equals(0));
      });

      test('can be set and retrieved', () {
        settingService.themeMode = 1;
        expect(settingService.themeMode, equals(1));
      });
    });

    group('themeFont', () {
      test('defaults to "system"', () {
        expect(settingService.themeFont, equals('system'));
      });

      test('can be set and retrieved', () {
        settingService.themeFont = 'Roboto';
        expect(settingService.themeFont, equals('Roboto'));
      });
    });

    group('useDynamicColor', () {
      test('defaults to true', () {
        expect(settingService.useDynamicColor, isTrue);
      });

      test('can be set and retrieved', () {
        settingService.useDynamicColor = false;
        expect(settingService.useDynamicColor, isFalse);
      });
    });

    group('useLowDataMode', () {
      test('defaults to true', () {
        expect(settingService.useLowDataMode, isTrue);
      });

      test('can be set and retrieved', () {
        settingService.useLowDataMode = false;
        expect(settingService.useLowDataMode, isFalse);
      });
    });

    group('transition', () {
      test('defaults to "cupertino"', () {
        expect(settingService.transition, equals('cupertino'));
      });

      test('can be set and retrieved', () {
        settingService.transition = 'fade';
        expect(settingService.transition, equals('fade'));
      });
    });

    group('textScaleFactor', () {
      test('defaults to 1.0', () {
        expect(settingService.textScaleFactor, equals(1.0));
      });

      test('can be set and retrieved', () {
        settingService.textScaleFactor = 1.5;
        expect(settingService.textScaleFactor, equals(1.5));
      });
    });

    group('readFontSize', () {
      test('defaults to 16', () {
        expect(settingService.readFontSize, equals(16));
      });

      test('can be set and retrieved', () {
        settingService.readFontSize = 20;
        expect(settingService.readFontSize, equals(20));
      });
    });

    group('readLineHeight', () {
      test('defaults to 1.5', () {
        expect(settingService.readLineHeight, equals(1.5));
      });

      test('can be set and retrieved', () {
        settingService.readLineHeight = 2.0;
        expect(settingService.readLineHeight, equals(2.0));
      });
    });

    group('readPagePadding', () {
      test('defaults to 18', () {
        expect(settingService.readPagePadding, equals(18));
      });

      test('can be set and retrieved', () {
        settingService.readPagePadding = 24;
        expect(settingService.readPagePadding, equals(24));
      });
    });

    group('readTextAlign', () {
      test('defaults to "justify"', () {
        expect(settingService.readTextAlign, equals('justify'));
      });

      test('can be set and retrieved', () {
        settingService.readTextAlign = 'left';
        expect(settingService.readTextAlign, equals('left'));
      });
    });

    group('useProxy', () {
      test('defaults to false', () {
        expect(settingService.useProxy, isFalse);
      });

      test('can be set and retrieved', () {
        settingService.useProxy = true;
        expect(settingService.useProxy, isTrue);
      });
    });

    group('proxyAddress', () {
      test('defaults to empty string', () {
        expect(settingService.proxyAddress, equals(''));
      });

      test('can be set and retrieved', () {
        settingService.proxyAddress = '192.168.1.1';
        expect(settingService.proxyAddress, equals('192.168.1.1'));
      });
    });

    group('proxyPort', () {
      test('defaults to empty string', () {
        expect(settingService.proxyPort, equals(''));
      });

      test('can be set and retrieved', () {
        settingService.proxyPort = '8080';
        expect(settingService.proxyPort, equals('8080'));
      });
    });

    group('serverHost', () {
      test('defaults to empty string', () {
        expect(settingService.serverHost, equals(''));
      });

      test('updateServerHost removes trailing slash', () {
        settingService.updateServerHost('https://example.com/');
        expect(settingService.serverHost, equals('https://example.com'));
      });

      test('updateServerHost keeps path without trailing slash', () {
        settingService.updateServerHost('https://example.com/api');
        expect(settingService.serverHost, equals('https://example.com/api'));
      });
    });

    group('remove', () {
      test('removes a key', () async {
        settingService.language = 'zh_CN';
        await settingService.remove('language');
        expect(settingService.language, equals('system')); // Back to default
      });
    });

    group('clean', () {
      test('clears all settings', () async {
        settingService.language = 'zh_CN';
        settingService.themeMode = 2;
        await settingService.clean();
        expect(settingService.language, equals('system'));
        expect(settingService.themeMode, equals(0));
      });
    });
  });
}
