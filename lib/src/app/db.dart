import 'package:sqflite/sqflite.dart';

void tao996AppDbCreate(Batch batch) {
  batch.execute('''
CREATE TABLE tao996_app_config (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  createdAt TEXT NOT NULL,
  updatedAt TEXT,
  deletedAt TEXT,
  gname TEXT NOT NULL DEFAULT '',
  name TEXT NOT NULL,
  value TEXT NOT NULL DEFAULT '',
  remark TEXT NOT NULL DEFAULT ''
);
''');
}
/*
-- 唯一索引
CREATE UNIQUE INDEX index_name ON table_name (column_name);
-- 联合索引
CREATE UNIQUE INDEX idx_feed_id_link ON post (feed_id, link)
-- 单例索引（注意：只能单独语句中创建）
CREATE INDEX index_name ON table_name (column_name);
-- 删除索引
DROP INDEX index_name;

-- 修改表结果
ALTER TABLE feed ADD state_index INTEGER NOT NULL DEFAULT 1

CREATE TABLE feed (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  grade INTEGER NOT NULL DEFAULT 0,
);
CREATE INDEX idx_feed_grade ON feed (grade);
*/