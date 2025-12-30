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

abstract class DbTypeModel<T> {
  Map<String, dynamic> toJson();

  Map<String, dynamic> toMap();

  /// 统一调用工厂方法 => T.fromMap(map);
  T fromMap(Map<String, dynamic> map);
}

abstract class IModel<T> extends DbTypeModel<T> {
  int id = 0;

  /// 创建时间
  DateTime? createdAt;

  /// 更新时间
  DateTime? updatedAt;

  /// 删除时间
  DateTime? deletedAt;

  IModel({this.id = 0, this.createdAt, this.updatedAt, this.deletedAt});

  bool hasRecord() {
    return id > 0;
  }

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

  String get createdAtText => DatetimeUtil.formatYMDHMS(dateTime: createdAt);

  String get updatedAtText => DatetimeUtil.formatYMDHMS(dateTime: updatedAt);

  String get deletedAtText => DatetimeUtil.formatYMDHMS(dateTime: deletedAt);

  void copyBaseDataFrom(dynamic model) {
    if (model != null && model is IModel) {
      id = model.id;
      createdAt = model.createdAt;
      updatedAt = model.updatedAt;
      deletedAt = model.deletedAt;
    }
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
