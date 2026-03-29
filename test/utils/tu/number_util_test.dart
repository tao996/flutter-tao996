import 'package:flutter_test/flutter_test.dart';
import 'package:tao996/src/utils/tu/number_util.dart';

void main() {
  group('NumberUtil', () {
    late NumberUtil numberUtil;

    setUp(() {
      numberUtil = const NumberUtil();
    });

    group('fenToYuan', () {
      test('converts fen to yuan correctly', () {
        expect(numberUtil.fenToYuan(10001), equals('100.01'));
        expect(numberUtil.fenToYuan(100), equals('1')); // trim defaults to true
        expect(numberUtil.fenToYuan(1), equals('0.01'));
        expect(numberUtil.fenToYuan(0), equals(''));
      });

      test('handles null and empty values', () {
        expect(numberUtil.fenToYuan(null), equals(''));
        expect(numberUtil.fenToYuan(''), equals(''));
      });

      test('returns 0.00 when emptyText is false', () {
        expect(numberUtil.fenToYuan(0, emptyText: false), equals('0.00'));
        expect(numberUtil.fenToYuan(null, emptyText: false), equals('0.00'));
      });

      test('trims .00 when trim is true', () {
        expect(numberUtil.fenToYuan(100, trim: true), equals('1'));
        expect(numberUtil.fenToYuan(10001, trim: true), equals('100.01'));
      });

      test('keeps .00 when trim is false', () {
        expect(numberUtil.fenToYuan(100, trim: false), equals('1.00'));
      });

      test('handles double input', () {
        expect(numberUtil.fenToYuan(100.0), equals('1')); // trim defaults to true
      });

      test('handles custom fractionDigits', () {
        expect(numberUtil.fenToYuan(100, fractionDigits: 4), equals('1.0000'));
      });
    });

    group('yuanToFen', () {
      test('converts yuan to fen correctly', () {
        expect(numberUtil.yuanToFen('100.01'), equals(10001));
        expect(numberUtil.yuanToFen('1'), equals(100));
        expect(numberUtil.yuanToFen('0.01'), equals(1));
      });

      test('handles strings with thousand separators', () {
        expect(numberUtil.yuanToFen('1,000.50'), equals(100050));
        expect(numberUtil.yuanToFen('1,000,000'), equals(100000000));
      });

      test('handles spaces in string', () {
        expect(numberUtil.yuanToFen('1 000.50'), equals(100050));
      });

      test('handles null and empty values', () {
        expect(numberUtil.yuanToFen(null), equals(0));
        expect(numberUtil.yuanToFen(''), equals(0));
      });

      test('handles invalid strings gracefully', () {
        expect(numberUtil.yuanToFen('invalid'), equals(0));
        expect(numberUtil.yuanToFen('abc'), equals(0));
      });

      test('rounds correctly to avoid floating point errors', () {
        // 100.01 * 100 = 10000.99999999999998 without rounding
        expect(numberUtil.yuanToFen('100.01'), equals(10001));
      });

      test('handles negative values', () {
        expect(numberUtil.yuanToFen('-10.50'), equals(-1050));
      });
    });

    // Note: parseInt and parseDouble methods depend on `tu.data` which requires
    // global initialization. These are integration tests, not unit tests.
    // group('parseInt', () { ... });
    // group('parseDouble', () { ... });

    group('formatNumber', () {
      test('formats numbers with commas', () {
        expect(numberUtil.formatNumber(1000), equals('1,000'));
        expect(numberUtil.formatNumber(1000000), equals('1,000,000'));
      });

      test('returns original data if not starting with number', () {
        expect(numberUtil.formatNumber('abc123'), equals('abc123'));
        expect(numberUtil.formatNumber(''), equals(''));
      });
    });

    group('startWithNumber', () {
      test('returns true for numbers', () {
        expect(numberUtil.startWithNumber(123), isTrue);
        expect(numberUtil.startWithNumber(123.45), isTrue);
      });

      test('returns true for number strings', () {
        expect(numberUtil.startWithNumber('123'), isTrue);
        expect(numberUtil.startWithNumber('1abc'), isTrue);
      });

      test('returns false for non-number strings', () {
        expect(numberUtil.startWithNumber('abc'), isFalse);
        expect(numberUtil.startWithNumber(''), isFalse);
      });

      test('returns false for null', () {
        expect(numberUtil.startWithNumber(null), isFalse);
      });

      test('throws for invalid types', () {
        expect(() => numberUtil.startWithNumber([]), throwsA(isA<String>()));
      });
    });

    group('formatNumberWithComma', () {
      test('formats integer with commas', () {
        expect(numberUtil.formatNumberWithComma(1000), equals('1,000'));
        expect(numberUtil.formatNumberWithComma(1000000), equals('1,000,000'));
      });

      test('formats double with commas', () {
        expect(numberUtil.formatNumberWithComma(1234.56), equals('1,234.56'));
      });

      test('handles string numbers', () {
        expect(numberUtil.formatNumberWithComma('1000'), equals('1,000'));
        expect(numberUtil.formatNumberWithComma('1,000'), equals('1,000'));
      });

      test('returns 0 for null', () {
        expect(numberUtil.formatNumberWithComma(null), equals('0'));
      });

      test('returns 0 for empty string', () {
        expect(numberUtil.formatNumberWithComma(''), equals('0'));
      });

      test('returns 0 for invalid string', () {
        expect(numberUtil.formatNumberWithComma('invalid'), equals('0'));
      });

      test('handles NaN', () {
        expect(numberUtil.formatNumberWithComma(double.nan), equals('0'));
      });

      test('formats with decimal digits', () {
        expect(numberUtil.formatNumberWithComma(1234.5678, decimalDigits: 2),
            equals('1,234.57'));
      });

      test('preserves trailing zeros when allowTrailingZeros is true', () {
        expect(
            numberUtil.formatNumberWithComma(1234.5,
                decimalDigits: 2, allowTrailingZeros: true),
            equals('1,234.50'));
      });

      test('removes trailing zeros when allowTrailingZeros is false', () {
        expect(
            numberUtil.formatNumberWithComma(1234.5000,
                decimalDigits: 4, allowTrailingZeros: false),
            equals('1,234.5'));
      });

      test('handles scientific notation', () {
        expect(numberUtil.formatNumberWithComma(1e10), isNot(contains('e')));
      });

      test('handles negative numbers', () {
        expect(numberUtil.formatNumberWithComma(-1234.56), equals('-1,234.56'));
      });

      test('rounds by default when round is true', () {
        expect(numberUtil.formatNumberWithComma(1234.5678, decimalDigits: 2),
            equals('1,234.57'));
        expect(numberUtil.formatNumberWithComma(1234.5644, decimalDigits: 2),
            equals('1,234.56'));
      });

      test('truncates when round is false', () {
        expect(numberUtil.formatNumberWithComma(1234.5678, decimalDigits: 2, round: false),
            equals('1,234.56'));
        expect(numberUtil.formatNumberWithComma(1234.9999, decimalDigits: 2, round: false),
            equals('1,234.99'));
      });

      test('truncates negative numbers correctly when round is false', () {
        expect(numberUtil.formatNumberWithComma(-1234.5678, decimalDigits: 2, round: false),
            equals('-1,234.56'));
        expect(numberUtil.formatNumberWithComma(-1234.9999, decimalDigits: 2, round: false),
            equals('-1,234.99'));
      });
    });

    group('formatDoubleWithRegex', () {
      test('removes trailing .0', () {
        expect(numberUtil.formatDoubleWithRegex(123.0), equals(123.0));
      });

      test('keeps decimals when needed', () {
        expect(numberUtil.formatDoubleWithRegex(123.45), equals(123.45));
      });
    });

    group('formatDouble', () {
      test('removes trailing .0 from string', () {
        expect(numberUtil.formatDouble('123.0'), equals('123'));
        expect(numberUtil.formatDouble('123.45'), equals('123.45'));
      });
    });

    group('sum', () {
      test('sums list of numbers', () {
        expect(numberUtil.sum([1, 2, 3, 4, 5]), equals(15));
        expect(numberUtil.sum([1.5, 2.5, 3.0]), equals(7.0));
      });

      test('returns 0 for empty list', () {
        expect(numberUtil.sum([]), equals(0.0));
      });
    });

    group('numGte', () {
      test('returns true when a >= b', () {
        expect(numberUtil.numGte(10, 5), isTrue);
        expect(numberUtil.numGte(5, 5), isTrue);
        expect(numberUtil.numGte('10', 5), isTrue);
      });

      test('returns false when a < b', () {
        expect(numberUtil.numGte(3, 5), isFalse);
      });

      test('returns false for null', () {
        expect(numberUtil.numGte(null, 5), isFalse);
      });

      test('returns false for invalid string', () {
        expect(numberUtil.numGte('invalid', 5), isFalse);
      });
    });

    group('numLte', () {
      test('returns true when a <= b', () {
        expect(numberUtil.numLte(3, 5), isTrue);
        expect(numberUtil.numLte(5, 5), isTrue);
        expect(numberUtil.numLte('3', 5), isTrue);
      });

      test('returns false when a > b', () {
        expect(numberUtil.numLte(10, 5), isFalse);
      });

      test('returns false for null', () {
        expect(numberUtil.numLte(null, 5), isFalse);
      });
    });

    group('numCompare', () {
      test('compares numbers correctly', () {
        expect(numberUtil.numCompare(5, 3), equals(1));
        expect(numberUtil.numCompare(3, 5), equals(-1));
        expect(numberUtil.numCompare(5, 5), equals(0));
      });

      test('compares strings correctly', () {
        expect(numberUtil.numCompare('5', '3'), equals(1));
        expect(numberUtil.numCompare('3', '5'), equals(-1));
      });

      test('compares mixed types', () {
        expect(numberUtil.numCompare(5, '3'), equals(1));
        expect(numberUtil.numCompare('3', 5), equals(-1));
      });

      test('returns -1 for null', () {
        expect(numberUtil.numCompare(null, 5), equals(-1));
        expect(numberUtil.numCompare(5, null), equals(-1));
      });

      test('returns -1 for invalid comparison', () {
        expect(numberUtil.numCompare('invalid', 5), equals(-1));
      });
    });

    group('getRandomElement', () {
      test('returns an element from the list', () {
        final list = [1, 2, 3, 4, 5];
        final result = numberUtil.getRandomElement(list);
        expect(list, contains(result));
      });

      test('throws for empty list', () {
        expect(() => numberUtil.getRandomElement([]),
            throwsA(isA<RangeError>()));
      });
    });

    group('getRandomInt', () {
      test('returns int in range', () {
        final result = numberUtil.getRandomInt(1, 10);
        expect(result, greaterThanOrEqualTo(1));
        expect(result, lessThan(10));
      });

      test('returns min when min == max - 1', () {
        expect(numberUtil.getRandomInt(5, 6), equals(5));
      });
    });

    group('getInts', () {
      test('parses comma-separated string', () {
        expect(numberUtil.getInts('1,2,3,4,5'), equals([1, 2, 3, 4, 5]));
      });

      test('filters out zeros and negatives', () {
        expect(numberUtil.getInts('0,1,-1,2'), equals([1, 2]));
      });

      test('handles spaces', () {
        expect(numberUtil.getInts('1, 2, 3'), equals([1, 2, 3]));
      });

      test('handles empty string', () {
        expect(numberUtil.getInts(''), equals([]));
      });
    });
  });
}
