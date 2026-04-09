import 'package:sqflite/sqflite.dart';
import 'package:tao996/tao996.dart';

/*
class MemberModule implements DbMigrateModule {
  @override
  void onCreate(Batch batch) {
    // 第一次建表，执行所有当前已知的最新结构
    _createTableV1(batch);
  }

  @override
  void onUpgrade(Batch batch, int oldVersion, int newVersion) {
    // 🎯 关键：让每个版本增量执行
    if (oldVersion < 2) {
      // 假设版本 2 增加了性别字段
      batch.execute('ALTER TABLE members ADD COLUMN gender TEXT DEFAULT "unknown"');
    }
    if (oldVersion < 3) {
      // 假设版本 3 增加了索引
      batch.execute('CREATE INDEX idx_members_name ON members (name)');
    }
  }

  void _createTableV1(Batch batch) {
    batch.execute('''
      CREATE TABLE members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        ...
      );
    ''');
  }
}
*/
/// 模块迁移接口
abstract class DbMigrateModule {
  final String id;

  /// 该模块当前代码中的最新版本
  final int version;

  DbMigrateModule(this.id, this.version);

  /// 处理第一次建表
  void onCreate(Batch batch);

  /// 处理版本升级
  /// [installVersion] 已经安装的版本
  void onUpgrade(Batch batch, int installVersion);
}

class MyDbMigrate {
  /// 数据库全局版本号（通常仅在系统表结构变动时增加）
  final int dbVersion;

  /// 注册的功能模块列表
  final List<DbMigrateModule> modules;

  MyDbMigrate(this.modules, {this.dbVersion = 1}) {
    // 1. 安全检查：防止模块 ID 冲突导致的版本记录覆盖
    final ids = <String>{};
    for (final module in modules) {
      if (!ids.add(module.id)) {
        throw Exception('❌ 数据库初始化失败：检测到重复的模块 ID -> ${module.id}');
      }
    }
  }

  Future<void> execute(
    SqfliteDatabaseService db, {
    Future<void> Function(Database, int)? onCreate,
    Future<void> Function(Database, int, int)? onUpgrade,
  }) async {
    // 标记是否正在创建数据库，用于防止 onOpen 和 onCreate 的竞态
    bool isCreating = false;

    // 这里的 dbService.migrate 是你自定义的服务封装
    await db.migrate((path) async {
      return await openDatabase(
        path,
        version: dbVersion,
        onCreate: (db, version) async {
          isCreating = true;
          try {
            // if the database did not exist
            var batch = db.batch();

            // 2. 创建元数据管理表（记录每个模块的版本）
            batch.execute('''
              CREATE TABLE _module_versions (
                module_id TEXT PRIMARY KEY,
                version INTEGER NOT NULL
              );
            ''');

            // 3. 初始化所有当前注册的模块
            for (var module in modules) {
              // 🎯 关键：在建表时立即记录版本，防止同步逻辑重复触发
              batch.insert('_module_versions', {
                'module_id': module.id,
                'version': module.version,
              });

              module.onCreate(batch);
            }

            if (onCreate != null) {
              await onCreate(db, version);
            }
            await batch.commit(noResult: true);
          } catch (e, stackTrace) {
            // 添加错误日志
            getILogService().e('数据库 onCreate 失败: $e\n$stackTrace');
            rethrow;
          } finally {
            isCreating = false;
          }
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (onUpgrade != null) {
            await onUpgrade(db, oldVersion, newVersion);
          }
          // 系统级升级逻辑（如果将来需要修改 _module_versions 表结构，在此处理）
          // 业务模块的升级将统一交给 _syncModules 处理
        },
        onOpen: (db) async {
          // 4. 🎯 核心逻辑：无论数据库是否刚刚创建，都执行自检
          // 这保证了"动态安装新模块"和"模块内部代码升级"能被正确识别

          // 如果仍在创建中，等待一小段时间确保 onCreate 的事务完全提交
          if (isCreating) {
            await Future.delayed(const Duration(milliseconds: 100));
          }

          // 添加重试机制处理 Android 下的 commit 失败问题
          int retries = 3;
          while (retries > 0) {
            try {
              await _syncModules(db);
              break;
            } catch (e, stackTrace) {
              retries--;
              if (retries == 0) {
                getILogService().e('数据库 _syncModules 最终失败: $e\n$stackTrace');
                rethrow;
              }
              getILogService().w('数据库 _syncModules 失败，剩余重试次数 $retries: $e');
              await Future.delayed(const Duration(milliseconds: 100));
            }
          }
        },
      );
    });
  }

  /// 模块同步逻辑：负责处理"新扩展安装"和"旧模块升级"
  Future<void> _syncModules(Database db) async {
    // 先检查表是否存在（防御性编程，防止竞态条件）
    final tableExists = await _checkTableExists(db, '_module_versions');
    if (!tableExists) {
      getILogService().w('_module_versions 表不存在，跳过同步');
      return;
    }

    // 获取已记录的所有模块版本
    final List<Map<String, dynamic>> records = await db.query(
      '_module_versions',
    );
    final Map<String, int> installedMap = {
      for (var row in records)
        row['module_id'] as String: row['version'] as int,
    };

    var batch = db.batch();
    bool hasChanges = false;

    for (var module in modules) {
      final int? installedVersion = installedMap[module.id];

      if (installedVersion == null) {
        // --- 场景 A：新安装的扩展模块 ---
        module.onCreate(batch);
        batch.insert('_module_versions', {
          'module_id': module.id,
          'version': module.version,
        });
        hasChanges = true;
      } else if (installedVersion < module.version) {
        // --- 场景 B：现有模块的版本升级 ---
        module.onUpgrade(batch, installedVersion);
        batch.update(
          '_module_versions',
          {'version': module.version},
          where: 'module_id = ?',
          whereArgs: [module.id],
        );
        hasChanges = true;
      }
    }

    if (hasChanges) {
      await batch.commit(noResult: true);
    }
  }

  /// 辅助方法：检查表是否存在
  Future<bool> _checkTableExists(Database db, String tableName) async {
    try {
      final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [tableName],
      );
      return result.isNotEmpty;
    } catch (e) {
      getILogService().e('检查表存在性失败: $e');
      return false;
    }
  }
}