import 'package:flutter_test/flutter_test.dart';
import 'package:tao996/src/helpers/query_builder.dart';

void main() {
  group('QueryBuilder', () {
    test('can add where condition', () {
      final builder = QueryBuilder<String>()
        ..where('name', '=', 'Alice');

      final (sql, args) = builder.build();
      expect(sql, equals('name = ?'));
      expect(args, equals(['Alice']));
    });

    test('can add multiple where conditions', () {
      final builder = QueryBuilder<String>()
        ..where('name', '=', 'Alice')
        ..where('age', '>', 18);

      final (sql, args) = builder.build();
      expect(sql, equals('name = ? age > ?'));
      expect(args, equals(['Alice', 18]));
    });

    test('can use andWhere for AND conditions', () {
      final builder = QueryBuilder<String>()
        ..where('name', '=', 'Alice')
        ..andWhere('age', '>', 18);

      final (sql, args) = builder.build();
      expect(sql, equals('name = ? AND age > ?'));
      expect(args, equals(['Alice', 18]));
    });

    test('andWhere without previous condition works like where', () {
      final builder = QueryBuilder<String>()
        ..andWhere('name', '=', 'Alice');

      final (sql, args) = builder.build();
      expect(sql, equals('name = ?'));
      expect(args, equals(['Alice']));
    });

    test('supports various operators', () {
      final builder = QueryBuilder<String>()
        ..where('age', '>=', 18)
        ..andWhere('age', '<=', 60)
        ..andWhere('name', '!=', 'test')
        ..andWhere('status', 'LIKE', '%active%');

      final (sql, args) = builder.build();
      expect(sql, contains('age >= ?'));
      expect(sql, contains('AND'));
      expect(args, equals([18, 60, 'test', '%active%']));
    });

    test('handles null values', () {
      final builder = QueryBuilder<String>()
        ..where('deleted_at', 'IS', null);

      final (sql, args) = builder.build();
      expect(sql, equals('deleted_at IS ?'));
      expect(args, equals([null]));
    });

    test('returns empty condition when no where called', () {
      final builder = QueryBuilder<String>();
      final (sql, args) = builder.build();
      expect(sql, equals(''));
      expect(args, isEmpty);
    });
  });

  group('DDLColumn', () {
    test('can create basic integer column', () {
      final column = DDLColumn('id', DDLColumnType.integer);
      expect(column.toString(), equals('id INTEGER'));
    });

    test('can create text column', () {
      final column = DDLColumn('name', DDLColumnType.text);
      expect(column.toString(), equals('name TEXT'));
    });

    test('can create real column', () {
      final column = DDLColumn('price', DDLColumnType.real);
      expect(column.toString(), equals('price REAL'));
    });

    test('can create primary key column', () {
      final column = DDLColumn(
        'id',
        DDLColumnType.integer,
        isPrimaryKey: true,
      );
      expect(column.toString(), equals('id INTEGER PRIMARY KEY'));
    });

    test('can create auto increment column', () {
      final column = DDLColumn(
        'id',
        DDLColumnType.integer,
        isPrimaryKey: true,
        isAutoIncrement: true,
      );
      expect(column.toString(), equals('id INTEGER PRIMARY KEY AUTOINCREMENT'));
    });

    test('auto increment only works with integer primary key', () {
      final column = DDLColumn(
        'id',
        DDLColumnType.text,
        isPrimaryKey: true,
        isAutoIncrement: true,
      );
      expect(column.toString(), equals('id TEXT PRIMARY KEY'));
    });

    test('can create unique column', () {
      final column = DDLColumn(
        'email',
        DDLColumnType.text,
        isUnique: true,
      );
      expect(column.toString(), equals('email TEXT UNIQUE'));
    });

    test('can create column with default value (integer)', () {
      final column = DDLColumn(
        'count',
        DDLColumnType.integer,
        defaultValue: '0',
      );
      expect(column.toString(), equals('count INTEGER DEFAULT 0'));
    });

    test('can create column with default value (text)', () {
      final column = DDLColumn(
        'status',
        DDLColumnType.text,
        defaultValue: 'active',
      );
      expect(column.toString(), equals("status TEXT DEFAULT 'active'"));
    });

    test('can create column with all properties', () {
      final column = DDLColumn(
        'id',
        DDLColumnType.integer,
        isPrimaryKey: true,
        isAutoIncrement: true,
        isUnique: true,
      );
      final result = column.toString();
      expect(result, contains('id'));
      expect(result, contains('INTEGER'));
      expect(result, contains('PRIMARY KEY'));
      expect(result, contains('AUTOINCREMENT'));
      expect(result, contains('UNIQUE'));
    });
  });

  group('DDLQueryBuilder', () {
    group('indexName', () {
      test('generates correct index name', () {
        expect(
          DDLQueryBuilder.indexName('users', 'email'),
          equals('idx_users_email'),
        );
      });

      test('generates index name with custom prefix', () {
        expect(
          DDLQueryBuilder.indexName('users', 'email', prefix: 'index_'),
          equals('index_users_email'),
        );
      });
    });
  });
}
