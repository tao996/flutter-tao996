// 1. 查询条件构建器类
import 'package:sqflite/sqflite.dart';

class QueryBuilder<T> {
  final List<String> _conditions = [];
  final List<Object?> _args = [];

  QueryBuilder<T> where(String field, String operator, dynamic value) {
    _conditions.add('$field $operator ?');
    _args.add(value);
    return this;
  }

  QueryBuilder<T> andWhere(String field, String operator, dynamic value) {
    if (_conditions.isNotEmpty) _conditions.add('AND');
    return where(field, operator, value);
  }

  (String, List<Object?>) build() {
    return (_conditions.join(' '), _args);
  }
}

enum DDLColumnType { integer, text, real }

class DDLColumn {
  final String name;
  final DDLColumnType type;
  bool isPrimaryKey;
  bool isAutoIncrement;
  bool isUnique;
  String defaultValue;

  /// 注意：不支持普通索引 index
  DDLColumn(
    this.name,
    this.type, {
    this.isPrimaryKey = false,
    this.isAutoIncrement = false,
    this.isUnique = false,
    this.defaultValue = '',
  });

  @override
  String toString() {
    List<String> parts = [];

    // 修正 Enum 转换问题
    parts.add(name);
    parts.add(type.name.toUpperCase());

    if (isPrimaryKey) parts.add('PRIMARY KEY');

    // SQLite 要求 AUTOINCREMENT 必须紧跟在 PRIMARY KEY 后面
    if (isAutoIncrement && isPrimaryKey && type == DDLColumnType.integer) {
      parts.add('AUTOINCREMENT');
    }

    if (isUnique) parts.add('UNIQUE');

    if (defaultValue.isNotEmpty) {
      // 针对文本类型处理引号
      final formattedDefault = type == DDLColumnType.text
          ? "'$defaultValue'"
          : defaultValue;
      parts.add('DEFAULT $formattedDefault');
    }

    return parts.join(' ');
  }
}

class DDLQueryBuilder {
  static void createTable(
    Database db, {
    required String tableName,
    required List<DDLColumn> columns,
  }) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        ${columns.map((column) => column.toString()).join(', ')}
      );
    ''');
  }

  static void addColumn(
    Database db, {
    required String tableName,
    required DDLColumn column,
  }) async {
    await db.execute('''
      ALTER TABLE $tableName ADD COLUMN ${column.toString()};
    ''');
  }

  static void dropColumn(
    Database db, {
    required String tableName,
    required String columnName,
  }) async {
    await db.execute('''
      ALTER TABLE $tableName DROP COLUMN $columnName;
    ''');
  }

  static void renameColumn(
    Database db, {
    required String tableName,
    required String columnName,
    required String newColumnName,
  }) async {
    await db.execute('''
      ALTER TABLE $tableName RENAME COLUMN $columnName TO $newColumnName;
    ''');
  }

  /// 唯一索引
  static void createUniqueIndex(
    Database db, {
    required String tableName,
    required String columnName,
  }) async {
    await db.execute(
      'CREATE UNIQUE INDEX idx_${tableName}_$columnName ON $tableName ($columnName)',
    );
  }

  /// 唯一联合索引
  static void createUniqueIndexWithColumns(
    Database db, {
    required String tableName,
    required List<String> columnNames,
  }) async {
    await db.execute(
      'CREATE UNIQUE INDEX idx_${tableName}_${columnNames.join('_')} ON $tableName (${columnNames.join(',')})',
    );
  }

  /// 普通索引
  static void createIndex(
    Database db, {
    required String tableName,
    required String columnName,
  }) async {
    await db.execute(
      'CREATE INDEX idex_${tableName}_${columnName}_index ON $tableName ($columnName)',
    );
  }

  /// 普通联合索引
  static void createIndexWithColumns(
    Database db, {
    required String tableName,
    required List<String> columnNames,
  }) async {
    await db.execute(
      'CREATE INDEX idx_${tableName}_${columnNames.join('_')} ON $tableName (${columnNames.join(',')})',
    );
  }

  /// 删除索引
  static void dropIndex(Database db, String indexName) async {
    await db.execute('DROP INDEX $indexName');
  }

  /// 索引是否存在
  static Future<bool> indexExists(Database db, String indexName) async {
    final result = await db.query(
      'sqlite_master',
      columns: ['name'],
      where: 'type = ? AND name = ?',
      whereArgs: ['index', indexName],
    );
    return result.isNotEmpty;
  }

  static String indexName(
    String tableName,
    String columnName, {
    String prefix = 'idx_',
  }) {
    return '$prefix${tableName}_$columnName';
  }
}
