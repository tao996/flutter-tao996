# API 参考

使用以下 API 必须导入 `import 'package:tao996/tao996.dart';`

## mixin

```dart
mixin MixinTao996Service {
  final IMessageService messageService = getIMessageService();
  final IDebugService debugService = getIDebugService();
}
```

### `IMessageService`

提供用户提示、确认对话框等功能，通常用在 `Controller` 中。

**核心方法：**

```dart
// 确认对话框
Future<bool?> confirm({
  String? title,
  String? content,
  String? cancelText,
  String? confirmText,
  void Function()? yes, // 点击确认时执行
  void Function()? no,
})

// 警告对话框
Future<void> alert(String title, {String? content, Widget? icon})

// 删除确认
Future<bool?> deleteConfirm(
  String text,
  void Function() yes, {
  bool textIsContent = false,
})

// Toast 提示
void toast(String message)

// Snackbar
SnackbarController snackbar(
  String title,
  String message, {
  SnackPosition snackPosition = SnackPosition.BOTTOM,
  bool? successIcon,
  int seconds = 3,
})

// 成功/错误提示
void success(String message, {bool snackBar = false})
void error(String message, {bool snackBar = false})
```


### `IDebugService`

用于打印日志，调试信息。

```dart
IDebugService d(
  Object? object, {
  Object? args,
  bool? log,
  String? errorMessage,
  String? successMessage,
});

/// 捕获异常，用在 try catch 中，会自动打印错误信息，并显示错误信息
IDebugService exception(
  Object error,
  StackTrace stackTrace, {
  Object? args,
  bool log = true,
  String? errorMessage,
});
```

### `MixinPositionCache`

用于记录滚动的位置

```dart
void savePosition(String key);
void restorePosition(String key); 
```

## 服务层 (Services)

### 数据库服务 `IDatabaseService`

提供数据库操作的抽象接口和 SQLite 实现

**核心方法：**

```dart
// 查询操作
Future<List<Map<String, dynamic>>> query(
  String table, {
  bool? distinct,
  List<String>? columns,
  String? where,
  List<Object?>? whereArgs,
  String? groupBy,
  String? having,
  String? orderBy,
  int? limit,
  int? offset,
})

// 插入操作
Future<int> insert(
  String table,
  Map<String, Object?> values, {
  ConflictAlgorithm? conflictAlgorithm,
})

// 更新操作
Future<int> update(
  String table,
  Map<String, Object?> values, {
  String? where,
  List<Object?>? whereArgs,
  ConflictAlgorithm? conflictAlgorithm,
})

// 删除操作
Future<int> delete(String table, {String? where, List<Object?>? whereArgs})

// 计数操作
Future<int> count(String tableName, {String? where, List<Object?>? arguments})

// 存在性检查
Future<bool> exists(String tableName, {String? where, List<Object?>? whereArgs})

// 获取第一条记录的指定字段值
Future<int> firstRecordId(
  String tableName, {
  String? where,
  List<dynamic>? whereArgs,
  String key = 'id',
})

// 执行事务
Future<M> transaction<M>(
  Future<M> Function(ModelTransaction mt) action, {
  bool? exclusive,
})

// 原生 SQL 执行
Future<void> execute(String sql, [List<Object?>? arguments])
Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<Object?>? arguments])
```

**使用示例：**

```dart
final db = getIDatabaseService();

// 查询
final results = await db.query('users', where: 'age > ?', whereArgs: [18]);

// 插入
final id = await db.insert('users', {'name': 'John', 'age': 25});

// 更新
final count = await db.update('users', {'age': 26}, where: 'id = ?', whereArgs: [id]);

// 删除
await db.delete('users', where: 'id = ?', whereArgs: [id]);

// 事务
await db.transaction((txn) async {
  await txn.txn.insert('users', {'name': 'Alice'});
  await txn.txn.insert('orders', {'user_id': 1});
});
```

#### 查询构建器 (Query Builder)

用于快速生成 `IDatabaseService` 查询条件

```dart
class QueryBuilder<T> {
  QueryBuilder<T> where(String field, String operator, dynamic value);
  QueryBuilder<T> andWhere(String field, String operator, dynamic value);
  (String, List<Object?>) build();
}
```

#### DDL

```dart

enum DDLColumnType { integer, text, real }

class DDLColumn {
  final String name;
  final DDLColumnType type;
  bool isPrimaryKey;
  bool isAutoIncrement;
  bool isUnique;
  String defaultValue;

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
    // return the sql
  }
}

class DDLQueryBuilder {
  static void createTable( Database db, {
    required String tableName,
    required List<DDLColumn> columns,
  });
  static void addColumn( Database db, {
    required String tableName,
    required DDLColumn column,
  });
  static void dropColumn( Database db, {
    required String tableName,
    required String columnName,
  });
  static void renameColumn( Database db, {
    required String tableName,
    required String columnName,
    required String newColumnName,
  });
  /// 唯一索引
  static void createUniqueIndex( Database db, {
    required String tableName,
    required String columnName,
  });
  /// 唯一联合索引
  static void createUniqueIndexWithColumns( Database db, {
    required String tableName,
    required List<String> columnNames,
  });
  /// 普通索引
  static void createIndex( Database db, {
    required String tableName,
    required String columnName,
  });
  /// 普通联合索引
  static void createIndexWithColumns( Database db, {
    required String tableName,
    required List<String> columnNames,
  });
  /// 删除索引
  static void dropIndex(Database db, String indexName);
  /// 索引是否存在
  static Future<bool> indexExists(Database db, String indexName);
  static String indexName( String tableName,String columnName, { String prefix = 'idx_',});
}
```

### 网络状态 `INetworkService`

监听网络状态变化。

**枚举类型：**

```dart
enum NetworkState {
  wifi(1),      // Wi-Fi
  cellular(7),  // 蜂窝数据
  no(4);        // 无网络
}
```

**核心属性和方法：**

```dart
Rx<NetworkState> state = (NetworkState.no).obs;

// 同步获取当前网络状态
NetworkState get currentNetworkState;

// 监听网络变化
Stream<List<ConnectivityResult>> get onConnectivityChanged;

// 状态判断
bool get isNoNetwork;
bool get isMobileNetwork;
bool get isWifi;

// 初始化和清理
void onInit({Future<void> Function()? callback});
void dispose();
```

### 系统设置 `ISettingsService`

管理应用设置，使用 SharedPreferences 持久化。

**核心属性：**

```dart
SharedPreferences get prefs
```

---

## 数据模型层 (Models & Helpers)

### 基础模型

模型使用 `@JsonSerializable()` 注释后，手动执行 `flutter pub run build_runner build` 以生成模型对应的 `g.dart` 文件，并自动生成以下方法。

```dart
Map<String, dynamic> toJson() => _$YourModelToJson(this);
Map<String, dynamic> toMap() => toJson();
YourModel fromMap(Map<String, dynamic> map) => YourModel.fromMap(map);
factory YourModel.fromJson(Map<String, dynamic> json) => _$YourModelFromJson(json);
factory YourModel.fromMap(Map<String, dynamic> map) => YourModel.fromJson(map);

class YourModelConverter implements JsonConverter<YourModel, String> {
  const YourModelConverter();

  @override
  YourModel fromJson(Object json) {
    if (json is String) return YourModel.fromJson(jsonDecode(json));
    return YourModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  String toJson(YourModel instance) => jsonEncode(instance.toJson());
}
```

以下类都实现了 `JsonConverter` 用于指定类型转换

* `@JsonColorConverter()` for `Color`
* `@JsonBoolConverter` for `bool`
* `@JsonMapStringStringConverter()` for `Map<String, String>`
* `@JsonNestedMapStringConverter()` for `Map<String, Map<String, String>>`
* `@JsonMapStringBoolConverter() ` form `Map<String, bool>`
* `@JsonMapStringIntConverter()` for `Map<String, int>`
* `@JsonMapStringDoubleConverter()` for `Map<String, double>`
* `@JsonListIntConverter()` for `List<int>`
* `@JsonListDoubleConverter()` for `List<double>`
* `@JsonListStringConverter()` for `List<String>`
* `@JsonRectConverter()` for `Rect`
* `@JsonSizeConverter()` for `Size`
* `@JsonOffsetConverter()` for `Offset`
* `@JsonEdgeInsetsConverter()` for `EdgeInsets`
* `@JsonBoxShadowConverter()` for `BoxShadow`
* `@JsonFontWeightConverter()` for `FontWeight`
* `@JsonBoxFitConverter()` for `BoxFit`
* `@JsonGradientConverter()` for `Gradient`

#### 数据库模型 `IModel<T>`

需要保存到数据库的模型

```dart
abstract class IModel<T> extends DbTypeModel<T> {
  int id = 0;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;

  IModel({this.id = 0, this.createdAt, this.updatedAt, this.deletedAt});

  // 检查是否有记录
  bool hasRecord() => id > 0;

  // 生成插入数据（自动移除 id）
  Map<String, dynamic> toInsertMap({
    bool addCreatedAt = true,
    bool addUpdatedAt = true,
  });

  // 格式化时间文本
  String get createdAtText;
  String get updatedAtText;
  String get deletedAtText;

  // 复制基础数据
  void copyBaseDataFrom(dynamic model);
  T copyBaseDataWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  });
}
```
**使用方式**

```dart
@JsonSerializable()
class YourModel extends IModel<YourModel> {
  // 无需定义 id、createdAt 等字段
  final String title;
  final String description;
  
  YourModel({
    required this.title,
    required this.description,
  });
  
  
}
```

#### 普通模型 `INoTimeModel<T>`

不需要保存到数据库，不包含时间戳的模型基类（JSON 序列化时忽略时间字段）。

### 模型助手 (Model Helper)

#### `ModelHelper<T extends IModel<T>>`

提供完整的数据库 CRUD 操作，支持缓存、软删除、事务等。

**核心功能：**

```dart
abstract class ModelHelper<T extends IModel<T>> {
  final String _tableName;
  final bool smallTable;         // if true, load all records in `getAll()`
  final bool enableSoftDelete;   // 是否启用软删除
  final bool enableCreatedAt;    // 是否有 createdAt 字段
  final bool enableUpdatedAt;    // 是否有 updatedAt 字段
  final bool enableUuid;         // 是否启用 uuid 字段

  ModelHelper(
    this._tableName, {
    this.smallTable = false,
    this.enableSoftDelete = false,
    this.enableCreatedAt = true,
    this.enableUpdatedAt = true,
    this.enableUuid = false,
  });

  /// 缓存字段映射（子类可重写，指定需要缓存的字段）
  Map<String, dynamic Function(T)> get cacheFieldGetters => {
    'id': (entity) => entity.id,
  };

  // 必须实现的转换方法
  T fromMap(Map<String, dynamic> map);

  // 生命周期钩子
  Future<bool> beforeInsert(T entity);
  Future<dynamic> afterInsert(T entity);
  Future<bool> beforeUpdate(T entity);
  Future<dynamic> afterUpdate(T entity);
  Future<bool> beforeSave(T entity, bool isInsert);
  Future<dynamic> afterSave(T entity, bool isInsert);
  Future<bool> beforeDelete({T? entity, String? where, List<Object?>? whereArgs});
  Future<dynamic> afterDelete(int deletedCount, {T? entity});

  // 查询操作
  Future<List<T>> getAll({bool force = false}); // 一次性将所有数据查询出来
  Future<T?> getFirstBy({required String fieldName, required dynamic value, bool tryCache = true, ModelTransaction? mtn});
  Future<T?> getFirstWith(String where, {List<Object?>? whereArgs, List<String>? columns, String? orderBy, ModelTransaction? mtn});
  Future<T?> getById(int id, {bool tryCache = true, ModelTransaction? mtn});
  Future<List<T>> getByIds(List<int> ids, {bool tryCache = true, ModelTransaction? mtn});
  Future<bool> exists(dynamic value, {required String fieldName,int? excludeId, String? excludeUuid,});
  Future<bool> Future<bool> existsWith({ String? where,List<Object>? whereArgs, int? excludeId,String? excludeUuid, });
  Future<int> count({String? where, List<Object?>? arguments, bool forceRefresh = false});
  Future<List<T>> getPaginationData({...});
  Future<List<T>> getManyBy({...});
  Future<List<Map<String, dynamic>>> getManyMapWith({...});
  Future<List<int>> getIdsWith({...});
  Future<List<int>> getListIntColumnWith(String column, {...});

  // 数据操作
  Future<int> updateWith(Map<String, Object?> values, {...});
  Future<int> update(T entity, {List<String>? columns, ModelTransaction? mtn});
  Future<int> delete({String? where, List<Object?>? whereArgs, T? entity, ModelTransaction? mtn});
  Future<int> deleteBy({required dynamic value, String fieldName = 'id', T? entity, ModelTransaction? mtn});
  Future<int> deleteById(int id, {ModelTransaction? mtn});
  Future<T> insertWith(Map<String, Object?> values, {ModelTransaction? mtn});
  Future<T> insert(T entity, {ModelTransaction? mtn});
  Future<List<int>> batchInsert(List<T> entities, {ModelTransaction? mtn, bool callback = false});

  // 事务操作
  Future<M> transaction<M>(Future<M> Function(ModelTransaction) action, {bool? exclusive});

  // 软删除相关
  Future<int> restore({String? where, List<Object?>? whereArgs, T? entity, ModelTransaction? mtn});
  Future<List<T>> getDeleted({String? where, List<Object?>? whereArgs});

  // 字段增减
  Future<void> increase(int id, String field, {int value = 1, ModelTransaction? mtn});
  Future<void> decrease(int id, String field, {int value = 1, ModelTransaction? mtn});

  // 原生 SQL
  Future<void> execute(String sql, {List<Object?>? arguments, ModelTransaction? mtn});
  Future<List<Map<String, dynamic>>> rawQuery(String sql, {List<Object?>? arguments});
}
```

**使用示例：**

```dart
class UserService extends ModelHelper<User> {
  UserService() : super('users', enableSoftDelete: true);

  @override
  User fromMap(Map<String, dynamic> map) => User.fromMap(map);
}

// 使用
final userService = UserService();
await userService.init('zh_CN');

// 查询
final users = await userService.getAll();
final user = await userService.getById(1);
final adults = await userService.getManyBy(where: 'age > ?', whereArgs: [18]);

// 插入
final newUser = User(name: 'Alice', age: 25);
final inserted = await userService.insert(newUser);

// 更新
user.name = 'Bob';
await userService.update(user);

// 删除
await userService.deleteById(user.id);

// 事务
await userService.transaction((mtn) async {
  await userService.insert(user1, mtn: mtn);
  await userService.insert(user2, mtn: mtn);
});
```



### 模型委托 (Model Delegate)

通常用在列表页控制器中，提供列表操作和数据库同步。

#### `MyModelDelegate<T extends IModel<T>>`

结合 ModelHelper 和响应式列表，提供列表操作和数据库同步，通常用在列表页控制器中。

```dart
abstract class AbstractListDelegate<T> {
  AbstractListDelegate<T>? _parentDelegate; // 父级代理
  RxList<T>? _rxItems;
  RxInt? _rxTotal;

   // 回调函数
  Future<void> Function(int index)? afterUpdate;
  Future<void> Function(T record)? afterInsert;
  Future<void> Function(T oldRecord, int index)? afterDelete;
  Future<void> Function(DelegateAction action, {T? record, int? index})?
  delegateCallback;

  AbstractListDelegate({
    AbstractListDelegate<T>? delegate, // parent delegate
    RxList<T>? rxItems,
    RxInt? rxTotal,
    bool autoInit = true,
  });

  void bind({
    RxList<T>? rxItems,
    RxInt? rxTotal,
    AbstractListDelegate<T>? delegate,
    Future<void> Function(int index)? afterUpdate,
    Future<void> Function(T record)? afterInsert,
    Future<void> Function(T oldRecord, int index)? afterDelete,
    Future<void> Function(DelegateAction action, {T? record, int? index})?
    delegateCallback,
  });
  /// 核心同步逻辑，同时更新 rxItems 和 rxTotal
  /// 删除: entity == null && index >= 0 触发 afterDelete 和 delegateCallback
  /// 添加: entity != null && index < 0 触发 afterInsert 和 delegateCallback
  /// 修改: entity != null && index >= 0 触发 afterUpdate 和 delegateCallback
  Future<void> sync({
    required int index,
    T? entity,
    bool unshift = true,
  });
}
class MyModelDelegate<T extends IModel<T>> extends AbstractListDelegate<T> {
  
  IMessageService get messageService; // ...
  ModelHelper<T> get helper; // ...
  bool get hasHelper; //...

  // 插入到最前面
  Future<void> insert(T entity, {bool syncDb = true, bool showMessage = true, bool navBack = true});

  // 追加到最后
  Future<void> push(T entity, {bool syncDb = true, bool showMessage = true, bool navBack = true});

  // 更新记录
  Future<void> update(T entity, int index, {bool syncDb = true, bool showMessage = true, bool navBack = true});
  
  // index > 0 call update; index < 0 call push 
  Future<void> save({required T entity, required int index, bool syncDb = true, bool showMessage = true, bool navBack = true, bool unshift = true,
  });

  // 删除记录
  Future<int> remoteAt({required int index, String? title, bool syncDb = true, bool deleteConfirm = true, bool showMessage = true, bool navBack = true});

  // 根据 ID 删除
  Future<int> removeWithId({required int id, int? index, String? title, bool syncDb = true, bool deleteConfirm = true, bool showMessage = true, bool navBack = true});

  // 通用触发器（保存或删除）
  // delegate set at ListController, `trigger` be called at DetailController
  Future<void> trigger(T? entity, int index, { bool syncDb = true, bool deleteConfirm = true, String? title, bool showMessage = true, bool navBack = true, });
}
```

### 模型操作 (Model Action)

#### `ModelAction<T extends IModel>`

链式调用模型操作，支持前后置回调。

```dart
class ModelAction<T extends IModel> {
  ModelAction addUpdate(Future<int> Function() action);
  ModelAction afterUpdateSuccess(Future<void> Function(int) callback);
  ModelAction addInsert(Future<T> Function() action);
  ModelAction afterInsertSuccess(Future<void> Function(T) callback);
  ModelAction addInsertLastId(Future<int> Function() action);
  ModelAction afterLastIdSuccess(Future<void> Function(int) callback);
  ModelAction addDelete(Future<int> Function() action);
  ModelAction afterDeleteSuccess(Future<void> Function(int) callback);
  ModelAction callback(Future<void> Function() callback);

  Future<void> execute({Future<void> Function()? success});
}
```

**使用示例：**

```dart
final action = ModelAction<User>();
action.addInsert(() => userService.insert(user))
      .afterInsertSuccess((newUser) async {
        print('插入成功: ${newUser.id}');
      })
      .execute(success: () {
        print('操作完成');
      });
```

### 模型迁移

```dart
abstract class DbMigrateModule {
  String get id;
  int get version;
  void onCreate(Batch batch);
  void onUpgrade(Batch batch, int installVersion);
}
```

## 工具类库 (Utils)

### 全局工具对象 `tu`

```dart

class _TUtils {
  const _TUtils();
  final path = const FilepathUtil();
  final file = const FileUtil();
  final color = const ColorUtil();
  final data = const DataUtil();
  final date = const DatetimeUtil();
  final fn = const FnUtil();
  final get = const GetUtil();
  final number = const NumberUtil();
  final permission = const PermissionUtil();
  final url = const UrlUtil();
  final zip = const ZipUtil();
  final device = const DeviceUtil();
  final context = const ContextUtil();
  final text = const TextUtil();
  final form = const FormHelperUtil();
  final draw = const DrawUtil();
  final font = const FontUtil();
  final api = const ApiUtil();
  final sd = const SmartDialogUtil();
}

const tu = _TUtils();
```

* 枚举辅助 `tu_header.dart`，用于 tu 中

```dart
typedef PickerFileType = FileType;
typedef PickerPlatformFile = PlatformFile;

/// 资源位置类型
enum ResourceLocation { local, network, assets, unknown }

/// 图片/视频选择类型
/// [camera] 拍照
/// [gallery] 从相册选择图片
/// [galleryVideo] 从相册选择视频
/// [cameraVideo] 拍摄视频
/// [media] 选择图片或视频
enum ImagePickerSource { camera, gallery, galleryVideo, cameraVideo, media }

/// 多选资源类型
/// [image] 仅图片
/// [medio] 媒体文件（图片+视频）
/// [video] 仅视频
enum ImagePickerMultipleSource { image, medio, video }

/// 日期时间格式化类型
/// [ym] 年月 (yyyy-MM)
/// [ymd] 年月日 (yyyy-MM-dd)
/// [ymdHm] 年月日时分 (yyyy-MM-dd HH:mm)
/// [ymdHms] 年月日时分秒 (yyyy-MM-dd HH:mm:ss)
/// [ymdFile] 年月日文件格式 (yyyyMMdd)
/// [ymdHmFile] 年月日时分文件格式 (yyyyMMdd-HHmm)
/// [ymdHmsFile] 年月日时分秒文件格式 (yyyyMMdd-HHmmss)
/// [hm] 时分 (HH:mm)
enum DateTimeFormat { ym, ymd, ymdHm, ymdHms, ymdFile, ymdHmFile, ymdHmsFile, hm }
```

#### get

服务 `get_it`, 控制器 `get` 的注册

```dart
class GetUtil {
  const GetUtil();
  T getService<T extends Object>() { return GetIt.instance<T>();}
  /// 注册服务
  void putService<T extends Object>(T dependency) {
    GetIt.instance.registerSingleton<T>(dependency);
  }
  void lazyPutService<T extends Object>(T Function() factoryFunc) {
    GetIt.instance.registerLazySingleton<T>(factoryFunc);
  }
  bool isServiceRegistered<T extends Object>() {
    return GetIt.instance.isRegistered<T>();
  }
  /// 获取控制器
  T getController<T extends Object>() {
    return Get.find<T>();
  }
  bool isControllerRegistered<T extends Object>() { return Get.isRegistered<T>();}
  
  S putController<S>(S dependency) { return Get.put(dependency); }

  void lazyPutController<T extends Object>(T Function() factoryFunc) { Get.lazyPut(factoryFunc);}

  dynamic arguments() {return Get.arguments;}
}
```


#### 路径 FilepathUtil

内部引入了 [path](https://pub.dev/packages/path)

* `String normalize(String userPath)` 标准化用户输入的文件或目录路径，并统一使用 '/' 作为分隔符。
* `bool isWindowsPath(String path)`
* `String separator()`, `String dirSeparator()`
* `List<String> split(String path)` => `p.split(path)`
* `String posixJoinAll(Iterable<String> parts)` => `p.posix.joinAll(parts)`
* `String joinAll(Iterable<String> parts)` => `p.joinAll(parts)`
* `String posixJoin(String part1, String part2 ...)` => `p.posix.join(part1, part2 ...)`
* `String join(String part1, String part2 ...)` => `normalize(p.join(part1, part2 ...))`
* `FileSystemEntityType getFileType(String path)` 获取路径类型
* `String relative(String path, {required String from})`
* `String dirname(String filePath)` 文件或目录所在的目录
* `String basename(String filePath)` 文件名+扩展名
* `String basenameWithoutExtension(String filePath)` 文件名
* `String extension(String filePath)` 扩展名
* `String withoutExtension(String filePath)`
* `bool isAbsolute(String path)`
* `String absolute(String part1, String part2 ...)`
* `String resolvePath(String filepath, {String? dir})`
* `String fromUri(Object? uri)`
* `String scriptDir()` 当前脚本所在目录
* `List<String> getFileNames(List<File> files)` 文件名列表
* `String? getMimeTypeFromPath(String filePath)` 
* `ResourceLocation determineLocation(String address)` 判断给定的地址是网络地址还是本地文件路径
* `bool exists(String path)` 检查文件或者目录是否存在


#### 文件操作 FileUtil

内部引入了 
* [file_picker](https://pub.dev/packages/file_picker)
* [image_picker](https://pub.dev/packages/image_picker)
* [file_selector](https://pub.dev/packages/file_selector)
* [flutter_image_gallery_saver](https://pub.dev/packages/flutter_image_gallery_saver)


```dart
/// 选择多个文件
Future<List<PlatformFile>?> pickPlatformFile({
  String? dialogTitle,
  String? initialDirectory,
  FileType type = FileType.any,
  List<String>? allowedExtensions,
  Function(FilePickerStatus)? onFileLoading,
  int compressionQuality = 0,
  bool allowMultiple = false,
  bool withData = false,
  bool withReadStream = false,
  bool lockParentWindow = false,
  bool readSequential = false,
});
/// 选择文件 [pickPlatformFile]，并返回它们的路径 [suggestExtensions] 常见的文件类型
Future<List<String>> pickFilesPath({
  bool allowMultiple = true,
  List<String>? allowedExtensions,
  bool suggestExtensions = true,
});
/// 选择文件 [pickPlatformFile] 并返回第1个选择文件的路径
Future<String?> pickFirstPath({List<String>? allowedExtensions});

/// 选择文件 [pickPlatformFile]，返回转换后的 [File]
Future<List<File>> pickFiles({
  FileType type = FileType.any,
  List<String>? allowedExtensions,
  String? initialDirectory,
  bool allowMultiple = false,
});

// 这会打开一个原生文件选择对话框，只允许用户选择目录，而不是文件。
Future<String?> getDirectory();

/// 选择文件并读取文件内容
Future<String?> getPickFileContent({
  FileType type = FileType.any,
  String? initialDirectory,
  List<String>? allowedExtensions,
});

/// 保存图片到用户相册
/// [file] 图片文件
/// [imageBytes] 图片字节数据
/// [image] ui.Image 对象，会自动转换为 Uint8List
/// [suggestedFileName] 建议文件名（PC 端使用）
Future<void> saveImageToGallery({
  File? file,
  Uint8List? imageBytes,
  ui.Image? image,
  String? suggestedFileName,
});

/// 保存文件到用户相册
Future<void> saveFileToGallery(String filePath);

/// 判断文件是否存在
bool exists(String filePath);

/// 异步计算给定文件的 MD5 哈希值
/// 返回一个 32 字符的十六进制字符串
Future<String> fileMd5(String filePath);

/// 读取文件内容为字符串
Future<String> getContent(String filePath);

/// 判断文件是否存在
bool exists(String filePath);

/// 异步计算给定文件的 MD5 哈希值
/// 返回一个 32 字符的十六进制字符串
Future<String> fileMd5(String filePath);

Future<String> getContent(String filePath) async;

/// 选择/拍摄一个图片或视频；
Future<XFile?> take({ ImagePickerSource source = ImagePickerSource.gallery,});

/// 返回选择/拍摄图片或视频的路径
Future<String?> taskPath({ ImagePickerSource source = ImagePickerSource.gallery,});

/// 从相册中选择多份文件
Future<List<XFile>?> pickXFilesFromGallery({ ImagePickerMultipleSource source = ImagePickerMultipleSource.image, });

/// 选择多份资源（默认图片），并返回路径
Future<List<String>> pickXFilePathFromGallery({ ImagePickerMultipleSource source = ImagePickerMultipleSource.image, });
```

#### 颜色 ColorUtil

```dart
bool isFullyTransparent(Color color);
bool isTransparent(Color color);
/// 创建一个 8x8 的棋盘背景,用于表示一个透明颜色
Widget buildCheckerboard({double squareSize = 8});
Color success();
Color error();
Color danger();
Color info();
Color warning();
Color text(double opacity);
Color hexToColor(String hexCode, {double opacity = 1.0});
Color rgbToColor(String rgbString, {double opacity = 1.0});
Color parseToColor(String input, {double opacity = 1.0});
```

#### 数据查询类 DataUtil



* `bool getBool(dynamic v, {bool defaultValue = false, bool textCompare = false,})`
* `bool getBoolFromInt(int value)` 只有 value == 1 时返回 true
* `int getInt(dynamic v, {int defaultValue = 0})`, 
* `int getIntFromBool(bool value)`
* `double getDouble(dynamic v, {double defaultValue = 0.0})`
* `String getString(dynamic v, {String defaultValue = ''})`
* `DateTime? getDateTime(dynamic v, { DateTime? defaultValue,String? formatPattern,}) `
* `List<T>? getList<T>( dynamic v,T Function(Map<String, dynamic>) fromJson, { List<T>? defaultValue, })`
* `dynamic firstValue(Map<String, dynamic> json, List<String> keys)` 获取第一个不为 null 的值
* `bool hasMatch(String data, String pattern)` 验证字符串 `[data]` 是否符合指定的正则表达式 `[pattern]`
* `List<String> getAllMatches(String pattern, String input)` 从字符串 `[input]` 中获取所有匹配项，匹配项的格式为 `[pattern]`
* `String? getFirstMatch(String pattern, String input)`
* `bool isValidUserInputRegexPattern(String pattern)` 验证用户输入的 `[pattern]` 是否为一个有效的正则表达式；注意跟原始字符串的区别
* `String getUserInputRegexPattern(String input)` 清除用户输入的正则表达式，返回一个可用户的系统正则表达式；
* `dynamic copy(dynamic data)` 通过 `jsonDecode(jsonEncode(data))` 复制数据
* `Type getType(dynamic data)` 获取数据运行时的类型
* `String generateMd5(String input)` 生成 md5

#### 网络数据请求 ApiUtil

```dart
class ApiUtil {
  // 获取响应数据
  Future<dynamic> getHttpResponseData(
    Future<HttpResponse> Function() apiRequest, {
    int successStatusCode = 200,
  });

  // 获取单个对象
  Future<T> fetchData<T>(
    Future<HttpResponse> Function() apiRequest,
    T Function(Map<String, dynamic>) itemBuilder,
  );

  // 获取分页数据
  Future<MyPaginatedResponse<T>> fetchPaginatedData<T>(
    Future<HttpResponse> Function() apiRequest,
    List<T> Function(List<Map<String, dynamic>>)? itemBuilder,
  );
}
```

#### SmartDialog 工具 (SmartDialogUtil)

基于 [flutter_smart_dialog](https://pub.dev/packages/flutter_smart_dialog) 的弹窗工具。

```dart
class SmartDialogUtil {
  // 显示加载中
  void showLoading(String message);
  void loading(); // 无文字加载
  void dismiss(); // 关闭弹窗
  void hideLoading(); // 关闭加载

  // 通知提示 (自动消失)
  void success({String? message, void Function()? onDismiss});
  void failure({String? message, void Function()? onDismiss});
  void warning({String? message, void Function()? onDismiss});
  void error(String message, {void Function()? onDismiss, bool clickMaskDismiss = false});
  void toast(String msg);
  void showToast(String msg);
  void notice(String message, {void Function()? onDismiss}); // Toast 通知

  // 弹窗
  Future<void> alert(String title, {String? content, Widget? icon});
}
```

#### 日期时间工具 (`DatetimeUtil`)

```dart
class DatetimeUtil {
  // 检查字符串是否匹配 ISO8601 格式 (YYYY-MM-DDTHH:MM:SS.mmmmmm)
  bool isIso8601FormatRegex(dynamic input);

  // 获取当前时间
  String getNowTime({String pattern = 'yyyy-MM-dd HH:mm:ss'});

  // 按 ymd 格式化 (快捷方法)
  String formatDate(DateTime datetime);

  // 按 ymdHms 格式化 (快捷方法)
  String formatDatetime(DateTime datetime);

  // 格式化日期
  String format({
    int timestamp = 0,
    DateTime? dateTime,
    String? iso8601,
    DateTimeFormat format = DateTimeFormat.ymdHms,
  });

  // 快捷格式化
  String formatYM({int timestamp = 0, DateTime? dateTime, String? iso8601});
  String formatYMD({int timestamp = 0, DateTime? dateTime, String? iso8601});
  String formatYMDHM({int timestamp = 0, DateTime? dateTime, String? iso8601});
  String formatYMDHMS({int timestamp = 0, DateTime? dateTime, String? iso8601});

  // 自定义格式格式化
  String formatWith(String format, DateTime datetime);

  // 解析日期，支持多种格式自动识别
  DateTime? parse(dynamic dateStr, {bool nowIfEmpty = false, String? formatPattern});

  // 比较两个日期
  int compareTo(dynamic a, dynamic b);

  // 获取时间戳
  // [l10] 10位秒级时间戳 (PHP 常用)
  // [l13] 13位毫秒级时间戳
  // 默认 16位微秒级时间戳
  int timestamp(DateTime dt, {bool l10 = false, bool l13 = false});

  // 格式化分钟数为易读格式 (如: 90分钟 -> "1h 30m")
  String formatMinutes(int totalMinutes);
}

// DateTime 扩展
extension DateTimeExt on DateTime {
  String formatYMD(); // 格式化为 YYYY-MM-DD
}
```

#### 设备信息 DeviceUtil

* `double get screenWidth` 屏幕宽度
* `double get screenHeight`
* `double get statusBarHeight`
* `String get platform` 小写的平台名称
* `bool get isPc`
* `bool get isMobile`
* `OS get runtimeOS`
* `bool hasCommand(String cmd)` 在本地运行命令
* `void copyToClipboard(String text)`
* `Future<Directory> getTemporaryDirectory()`
* `Future<Directory> getApplicationDocumentsDirectory()`
* `Future<Directory> getApplicationSupportDirectory() `
* `Future<Directory> getApplicationCacheDirectory()`
* `Future<Directory?> getDownloadsDirectory()`
* `Future<String> homeDir()` 用户家目录


#### 数字处理 NumberUtil

* `String formatMoney( dynamic num, { int fractionDigits = 2, bool emptyText = true, bool trim = true, })` 将实际的金额（分，int）格式化成字符串（元，String），比如数据库中的 10001 分转换成 "100.01" 元。
* `int parseMoney(String? money)` 将用户输入的元（String）转换成分（int），以便保存到数据库中,比如 "100,100.01" 元转换成 10010001 分。
* `int parseInt(String? value)`
* `bool startWithNumber(dynamic data)`
* `String formatNumber(dynamic data)` 只有数字/数字字符串才会被处理
* `String formatNumberWithComma( dynamic number, { int? decimalDigits, bool allowTrailingZeros = false, })` 将多种类型的数字格式化为带逗号分隔的字符串
* `double formatDoubleWithRegex(double value)` 去掉小数点后多余的0
* `String formatDouble(String s) `
* `num sum(List<num> list)`
* `bool numGte(dynamic a, int b)`
* `bool numLte(dynamic a, int b)`
* `int numCompare(dynamic a, dynamic b) `

#### 字符串处理 TextUtil

* `String merge( String separator, String text0, [ String? text1, ...]`

#### 栈追踪工具 StackUtil

用于调试时打印栈信息，帮助定位问题。

```dart
class StackUtil {
  /// 允许打印的包名列表
  static final List<String> debugPackages = ['package:tao996'];

  /// 添加包名到调试列表
  static void logPackages(List<String> packages, {bool append = true});

  /// 打印栈信息
  static void output({
    required String color,        // 输出颜色
    List<String>? filterNames,    // 过滤掉的类名
    bool first = false,           // 只打印第一条
  });

  /// 获取栈追踪字符串列表
  static List<String> getStackTraceString({StackTrace? stackTrace});
}
```

#### UrlUtil

* `bool hasAbsolutePath(String uri)`
* `bool isAbsoluteWebUri(String uriString)`
* `Uri concat(String host, String path)` 连接主机与路径， `[host]` 主机；`[path]` 路径
* `String host(String url)`
* `String? encodeQueryParameters(Map<String, String> params)` 编码 URL 查询参数
* `Future<bool> launch( String url, { String? title, LaunchMode? mode, Function()? error, })` 内部使用 [url_launcher](https://pub.dev/packages/url_launcher)

#### 压缩解压缩 ZipUtil

内部使用了 [archive](https://pub.dev/packages/archive)

```dart
/// 压缩文件
/// [zipFilePath] 压缩包名称, [password] 解压密码
/// [workingDirectory] 工作目录，如果存在，则会与 [zipFilePath] 及 [filePaths]的各部分进行拼接
Future<void> encode(
  String zipFilePath,
  List<String> filePaths, {
  String? workingDirectory,
  String? password,
  String app = 'zip',
}) 
/// 解压文件
/// [zipFilePath] 压缩包名称, [password] 解压密码
/// [destinationPath] 解压目录
/// [workingDirectory] 工作目录，如果存在，则会与 [zipFilePath] 和 [destinationPath] 进行拼接
Future<void> decode(
  String zipFilePath,
  String destinationPath, {
  String? workingDirectory,
  String? password,
}) 
```

#### 表单 FormHelperUtil

```dart
/// 网络布局的 checkbox 按钮组
/// [crossAxisCount] 列数，会根据列数自动计算自身的尺寸
/// 跟 FlowChipBar 有点类似，但 FlowChipBar 是单选，并且不是网络布局
Widget gridCheckbox({
  required List<String> items,
  required ValueChanged<List<String>> onSelectionChanged,
  List<String>? values,
  int crossAxisCount = 3,
  double horizontal = 18,
});
/// 列表布局的 checkbox 复选列表（占据最宽），可用于多项选择
Widget listCheckbox<T>({
  required List<KV<T>> items,
  required ValueChanged<List<T>> onSelectionChanged,
  List<T>? values,
  bool dense = false,
});
/// 水平布局的 按钮组，可用于多单或单选（oneFilterChip），被选中的选项会打上一个勾（改变了尺寸）
/// 跟 [gridCheckbox] 的区别是会自动换行，你可以需要将这个组件包裹在 Expanded 中
Widget filterChipCheckbox<T>({
  required List<KV<T>> items,
  required void Function(bool selected, T item) onSelectionChanged,
  List<T>? values,
}) 
/// 水平布局的 按钮组，可用于单选
Widget oneFilterChip<T>({
  required List<KV<T>> items,
  required void Function(T? item) onSelectionChanged,
  T? value,
  String? label,
  InputDecoration? decoration, // 允许传入自定义 decoration
  bool isRequired = false,
})
/// 分段按钮，2-3个选项时可使用，如果选项太多或内容太长则不建议使用，因为文字换行显示很难看
/// [multiSelectionEnabled] 是否支持多选; [emptySelectionAllowed] 是否允许空选项
Widget segmentedButton<T>({
  required List<KV<T>> items,
  required void Function(Set<T> items) onSelectionChanged,
  required List<T> values,
  bool multiSelectionEnabled = false,
  bool emptySelectionAllowed = true,
}) ;
/// 单选分段按钮
Widget oneSegmentedButton<T>({
  required List<KV<T>> items,
  required void Function(T value) onSelectionChanged,
  T? value,
  String? label,
  bool isRequired = false,
}) ;
Widget radioGroup<T>({
  required List<KV<T>> items,
  T? value,
  required void Function(T value) onSelectionChanged,
  bool horizontal = true,
});
/// 水平列表框
Widget select<T>({
  required String label,
  required List<KV<T>> items,
  required ValueChanged<T?> onChanged,
  T? value,
  String? hintText,
  String? helperText,
  bool isRequired = false,
});
// input will auto set keyboardType
Widget input({
  TextEditingController? controller,
  String? labelText,
  String? hintText,
  String? helperText,
  String? defaultValue,
  bool isPassword = false,
  bool isRequired = false,
  num? minNumber, // 最小值限制
  num? maxNumber, // 最大值限制
  bool isInteger = false,
  bool isDouble = false,
  bool isMoney = false,
  int? maxLines,
  int? minLines,
  Widget? suffix,
  TextAlign textAlign = TextAlign.start,
  void Function(String)? onChanged,
  void Function(String)? onSubmit,
  String? Function(String?)? validator,
});
Widget dateInput({
  DateTime? initDate,
  required String labelText,
  required Function(DateTime?) onDateSelected,
  String? hintText,
});
Widget timeInput({
  DateTime? initTime,
  required String labelText,
  required Function(DateTime?) onTimeSelected,
  String? hintText,
});
Widget datetimeInput({
  DateTime? initialDatetime,
  required String labelText,
  required Function(DateTime?) onDatetimeSelected,
  String? hintText,
});
Widget checkboxListTile({
  required String title,
  required void Function(bool) onChanged,
  String? subtitle,
  bool value = false,
  IconData? iconData,
});
/// 一个普通的简单复选组件
Widget checkbox(
  String label, {
  bool? value,
  required void Function(bool?)? onChanged,
  String? helperText,
  bool helperTextBottom = true,
})
/// 搜索框 [data] 原始数据，在用户输入或提交时会同时将原始数据返回
Widget search(
  MySearchInputMethods method, {
  double fontSize = 16,
  String? hintText,
  String? value,
  dynamic data,
});
/// 用来模拟一个输入框，如果只是单纯需要显示文字，使用 MyText.label
InputDecorator inputDecoration(
  String label,
  Widget child, {
  InputDecoration? decoration,
  bool isRequired = false,
  String? helperText,
});
/// PC: 左侧控件 + 右侧控件
Widget leftWidgetRightWidget({
  required Widget right,
  Widget? left,
  double? width,
  EdgeInsetsGeometry? padding,
  bool pZero = false,
});
Widget leftNullRightWidget(Widget child, {EdgeInsetsGeometry? padding});
Widget leftStringRightWidget(
  String label, {
  required Widget child,
  bool isRequired = false,
  double? width,
});
```

#### 绘画 DrawUtil

```dart
Future<ui.Image> renderImage(String path);
Future<ui.Image> renderSvgWithUrl(String url);
Future<ui.Image> renderSvg(String svgContent, { Size size = const Size(512, 512),});
Future<ui.Image> renderText(
  String text, {
  required Size size,
  double? fontSize,
  Color? color,
  String? fontFamily,
  FontWeight? fontWeight,
  double pixelRatio = 3.0,
});
```

## 翻译系统 (Translation)

### `TranslationService`

支持多语言翻译，基于 GetX Translations。

**支持的语言：**

| 语言 | 代码 | Locale |
|------|------|--------|
| 简体中文 | zh_CN | Locale('zh', 'CN') |
| 繁体中文 | zh_TW | Locale('zh', 'TW') |
| English | en_US | Locale('en', 'US') |
| 日本語 | ja_JP | Locale('ja', 'JP') |
| Deutsch | de_DE | Locale('de', 'DE') |
| Français | fr_FR | Locale('fr', 'FR') |
| Español | es_ES | Locale('es', 'ES') |

**核心方法：**

```dart
class TranslationService extends Translations {
  Map<String, Map<String, String>> get keys;

  // 添加字典
  void addDict(Map<String, Map<String, String>> newKeys);

  // 添加翻译
  void addKeys(Map<String, String> newKeys, {String locale = 'zh_CN'});

  /// 加载翻译文件 [jsonPth] `lib/extensions/app_beian/i18n/zh_CN.json`
  /// only run in kDebugMode
  Future<void> addJsonFile(String jsonPth, {String locale = 'zh_CN'});
}
```

**使用翻译：**

```dart
// 基本翻译
Text('confirm'.tr)

// 带参数翻译
Text('deleteConfirmContent'.trParams({'title': 'User'}))

// 动态添加翻译
getTranslationService().addKeys({
  'customKey': '自定义翻译',
}, locale: 'zh_CN');
```

## 辅助函数

**导航辅助函数：**

```dart
void goBackWithResult(dynamic result);
void goBack();
```

### `KV<T>`

键值对类，通常用在 `tu.form` 表单中

```dart
class KV<T> {
  final String label;
  final T value;

  KV({required this.label, required this.value});
}

/// 用于创建 KV 列表
List<KV<T>> kvCreateList<T extends Enum>(Map<T, String> maps);

extension KVList<T extends Enum> on List<KV<T>> {
  T? getValue(String? name);
  List<String> labels();
  List<T> values();
}
```

## UI 和控制器

### MyScaffold

集成 SafeArea 的 Scaffold 组件，简化页面布局。

```dart
class MyScaffold extends StatelessWidget {
  final AppBar? appBar;
  final Widget? drawer;
  final Widget body;
  final Widget? floatingActionButton;

  /// [singleChildScrollView] 在滚动方向（垂直）上，不给其子 Widget 任何约束
  /// 默认为 false，表示你可以在 Column 中使用 Expanded
  final bool singleChildScrollView;

  final bool useSafeArea;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Color? backgroundColor;

  /// [drawerEdgeDragWidthPercent] 定义一个宽度区域，在这个区域内水平拖动可以触发打开 drawer
  final double? drawerEdgeDragWidthPercent;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
}

/// 适用于子内容不包含 `Expanded` 的页面
class MyMiniScaffold extends StatelessWidget {
  final AppBar appBar;
  final List<Widget> children;
  final Widget? floatingActionButton;
}

/// AppBar 菜单按钮组
class MyAppBarMenuButtons extends StatelessWidget {
  final void Function(String) onSelected;
  final List<List<MyAppBarMenuItem>> items;
}

/// 空状态 Widget（当页面没有记录时显示）
class MyEmptyStateWidget extends StatelessWidget {
  final String? buttonText;    // 按钮文字
  final VoidCallback? onAction; // 点击回调
  final String? title;         // 内容类型描述
  final Widget? child;         // 追加的自定义组件
  final bool showDesc;         // 是否显示描述
}
```

### CustomTabBar

通常用于多个分组时，需要单独显示分组的内容，对 `TabBarView` 的优化；

```dart
/// `horizontal` 水平滚动 + 激活时：显示下划线；
/// `flow` 自动换行 + 激活时：显示下划线；
/// `bookMark` 水平滚动 + 激活时：显示圆角背景；
/// `flowChip` 自动换行 + 激活时：显示圆角边框；
enum MyCustomTabBarStyle { bookMark, horizontal, flow, flowChip }

class MyCustomTabBarItem {
  final String key;
  final String title;
}

class MyCustomTabBar extends StatefulWidget {
  /// 高度
  final double height;

  /// 子项：注意，你不能把 RxList 直接传进来，否则会引起 Unhandled Exception: Stack Overflow；
  /// 应该传 RxList.value
  final List<MyCustomTabBarItem> children;

  /// 当前选中的标签索引
  final RxInt activeIndex;
  final void Function(int index) onChange;
  final void Function(int index)? onDoubleTap;

  /// 默认为水平排列
  final MyCustomTabBarStyle style;

  /// 选中的 TabBar 背景色，默认为 theme.scaffoldBackgroundColor
  final Color? notebookBgColor;

  /// 最后一个标签添加按钮
  final void Function()? onInsert;

  const MyCustomTabBar({
    super.key,
    this.height = 50,
    this.style = MyCustomTabBarStyle.horizontal,
    required this.activeIndex,
    required this.onChange,
    this.onDoubleTap,
    required this.children,
    this.notebookBgColor,
    this.onInsert,
  });
}
```

### QRCodeView

二维码扫描页面

```dart
Get.back(result: scanData.code);
```

### MySmartRefresher

一个自动管理下拉刷新，上拉加载的列表组件，使用示例

#### MySmartRefresherController

控制器，管理数据的加载

```dart
abstract class MySmartRefresherController<T> extends IMySmartRefresherBodyController {
  AbstractListDelegate<T> delegate;
  int pageIndex = 1;
  int pageSize = 15;
  final RxBool hasMore = true.obs;
  RxList<T> get items => delegate.rxItems;
  RxBool isRequesting = false.obs;
}
```

```dart
class Student {
  final String name;
}

/// 定义控制器
class MyDemoSmartRefresherController extends MySmartRefresherController<Student> {
  /// 返回每次刷新或加载时需要返回的数据
  @override
  Future<List<Student>?> loadData() async {
      return await _helper.getPaginationData(where: _getWhere(), pageSize: pageSize,pageIndex: pageIndex,);
  }
  /// 返回查询的条件
  String _getWhere() {}
}


class MyDemoSmartRefresherPage extends StatelessWidget {
  late final MyDemoSmartRefresherController c;

  MyDemoSmartRefresherPage({super.key}) {
    c = Get.put(MyDemoSmartRefresherController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('DEMO SmartRefresher')),
      body: SafeArea(
        child: Obx( () => MySmartRefresher.obxListView( c,
          canLoadMore: c.hasMore,
            empty:  MyEmptyStateWidget(
              title: 'student'.tr, onAction: c.bindInsertRecord,
            ),
            itemCount: c.items.value.length,
            itemBuilder: (context, index) {
              final student = c.items[index];
              return ListTile(title: Text(student.name));
            },
         ))),
      );
  }
}
```