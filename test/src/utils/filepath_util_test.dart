import 'package:flutter_test/flutter_test.dart';
import 'package:tao996/tao996.dart';

void main() {
  group('filepath util', () {
    test('methods', () {
      final winPaths = [
        ['C:\\Users\\John\\Documents', true],
        ['D:\\Projects\\Flutter\\app.dart', true],
        ['E:\\', true],
        ['\\\\Server\\Share', true],
        ['file.txt', false],
        ['.\\path\\to\\file', true],
        ['..\\up\\folder', true],
        ['\\Program Files\\', false],
        ['C:/Users/John/Documents', false],
        ['/home/user/documents', false],
        ['https://example.com', false],
        ['just a string', false],
      ];
      for (final item in winPaths) {
        expect(
          FilepathUtil.isWindowsPath(item[0] as String),
          item[1] as bool,
          reason: '${item[0] as String} test failed',
        );
      }

      expect(FilepathUtil.normalizeToPosixPath('C:\\a\\b.txt'), 'C:/a/b.txt');

      expect(FilepathUtil.joinAll(['/a', 'b\\c']), '/a/b\\c');
      expect(FilepathUtil.normalizeToPosixPath('/a/b\\c'), '/a/b/c');
    });
  });
}
