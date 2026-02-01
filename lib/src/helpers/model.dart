import 'package:json_annotation/json_annotation.dart';
/*
await db.execute('''CREATE TABLE $_tableName(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  createdAt TEXT NOT NULL,
  updatedAt TEXT,
  deletedAt TEXT,
  -- ... 其他字段 ...
)
''');
 */
import 'package:tao996/tao996.dart';

/// 使用 xxx extends `DbTypeModel<xxx>`
abstract class DbTypeModel<T> {
  Map<String, dynamic> toJson();

  Map<String, dynamic> toMap();

  /// 统一调用工厂方法 => T.fromMap(map);
  T fromMap(Map<String, dynamic> map);
}

abstract class IModel<T> extends DbTypeModel<T> {
  int id = 0;

  bool hasRecord() {
    return id > 0;
  }

  /// 创建时间
  DateTime? createdAt;

  /// 更新时间
  DateTime? updatedAt;

  /// 删除时间
  DateTime? deletedAt;

  /// 通过 `User(int id, this.name):super(id: id);` 来初始化 id
  IModel({this.id = 0, this.createdAt, this.updatedAt, this.deletedAt});

  Map<String, dynamic> toInsertMap({
    bool addCreatedAt = true,
    bool addUpdatedAt = true,
  }) {
    if (addCreatedAt) {
      createdAt = createdAt ?? DateTime.now();
    }
    if (addUpdatedAt) {
      updatedAt = updatedAt ?? DateTime.now();
    }
    final data = toMap();
    data.remove('id');
    return data;
  }

  String get createdAtText => tu.date.formatYMDHMS(dateTime: createdAt);

  String get updatedAtText => tu.date.formatYMDHMS(dateTime: updatedAt);

  String get deletedAtText => tu.date.formatYMDHMS(dateTime: deletedAt);

  void copyBaseDataFrom(dynamic model) {
    if (model != null && model is IModel) {
      id = model.id;
      createdAt = model.createdAt;
      updatedAt = model.updatedAt;
      deletedAt = model.deletedAt;
    }
  }

  T copyBaseDataWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    if (id != null) {
      this.id = id;
    }
    if (createdAt != null) {
      this.createdAt = createdAt;
    }
    if (updatedAt != null) {
      this.updatedAt = updatedAt;
    }
    if (deletedAt != null) {
      this.deletedAt = deletedAt;
    }
    return this as T;
  }
}

abstract class INoTimeModel<T> extends IModel<T> {
  INoTimeModel({super.id});

  /// 创建时间
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  DateTime? createdAt;

  /// 更新时间
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  DateTime? updatedAt;

  /// 删除时间
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  DateTime? deletedAt;
}
