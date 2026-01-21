# API 参考

使用以下 API 必须导入 `import 'package:tao996/tao996.dart';`


#### 全局服务获取函数

```dart
// 数据库服务
IDatabaseService getIDatabaseService()
SqfliteDatabaseService getSqfliteDatabaseService()

// 功能服务
IMessageService getIMessageService()
INetworkService getINetworkService()
IThemeService getIThemeService()
IRouteService getIRouteService()
ILocaleService getILocaleService()
IShareService getIShareService()
IFilePickerService getIFilePickerService()
IWebviewService getIWebviewService()

// 工具服务
IDebugService getIDebugService()
ILogService getILogService()
IDioHttpService getIDioHttpService()
IFontService getIFontService()
IPathService getIPathService()

// 翻译服务
TranslationService getTranslationService()
```

---

## 服务层 (Services)

### 数据库服务 (Database Service)

#### `IDatabaseService` / `SqfliteDatabaseService`

提供数据库操作的抽象接口和 SQLite 实现。

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

---

### 消息服务 (Message Service)

#### `IMessageService` / `MessageService`

提供用户提示、确认对话框等功能。

**核心方法：**

```dart
// 确认对话框
Future<bool?> confirm({
  String? title,
  String? content,
  String? cancelText,
  String? confirmText,
  void Function()? yes,
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

---

### 网络状态服务 (Network Service)

#### `INetworkService` / `NetworkService`

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

---

### 设置服务 (Settings Service)

#### `ISettingsService` / `SettingService`

管理应用设置，使用 SharedPreferences 持久化。

**核心属性：**

```dart
SharedPreferences get prefs
```

---

## 数据模型层 (Models & Helpers)

### 1. 基础模型

#### `IModel<T>`

所有数据模型的基类，提供标准字段和方法。用户需要手动执行 `flutter pub run build_runner build` 以生成模型对应的 `g.dart` 文件。

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
}
```

#### `DbTypeConverter` 模型属性注解

内部都是静态方法，为模型属性添加转换器，成对使用。

* 用于 `bool` 类型的 `static bool boolFromJson(int value)`,`static int boolToJson(bool value)`
* `static String mapStringToJson(Map<String, String>? data)`, `static Map<String, String> mapStringFromJson(String? json)`
* `static String mapBoolToJson(Map<String, bool>? data)`, `static Map<String, bool> mapBoolFromJson(String? json)`
* `static String mapIntToJson(Map<String, int>? data)`, `static Map<String, int> mapIntFromJson(String? json)`
* `static String mapDoubleToJson(Map<String, double>? data)`, `static Map<String, double> mapDoubleFromJson(String? json)`
* `static String mapToJson<T extends DbTypeModel<T>>(Map<String, T>? data)` 和 `static Map<String, T> mapFromJson<T extends DbTypeModel<T>>( String? json, {required T Function(Map<String, dynamic>) fromMap,})`，mapFromJson 无法直接使用，需要在使用中二次调用
* `static String listToJson<T extends DbTypeModel<T>>(List<T>? items)`,`static List<T> listFromJson<T extends DbTypeModel<T>>`
* `static List<int> listIntFromJson(String? json)`, `static String listIntToJson(List<int>? items)`
* `static List<double> listDoubleFromJson(String? json)`, `static String listDoubleToJson(List<double>? items)`
* `static List<String> listStringFromJson(String? json)`, `static String listStringToJson(List<String>? items)`

```dart
import 'package:json_annotation/json_annotation.dart';

@JsonKey(
  fromJson: DbTypeConverter.boolFromJson,
  toJson: DbTypeConverter.boolToJson,
)
final bool required;

@JsonKey(
  fromJson: DbTypeConverter.mapStringFromJson,
  toJson: DbTypeConverter.mapStringToJson,
)
final Map<String, String> options;
```

#### `INoTimeModel<T>`

不包含时间戳的模型基类（JSON 序列化时忽略时间字段）。

---

### 2. 模型助手 (Model Helper)

#### `ModelHelper<T extends IModel<T>>`

提供完整的数据库 CRUD 操作，支持缓存、软删除、事务等。

**核心功能：**

```dart
abstract class ModelHelper<T extends IModel<T>> {
  final String _tableName;
  final bool enableCache;        // 是否启用缓存
  final bool enableSoftDelete;   // 是否启用软删除
  final bool enableCreatedAt;    // 是否有 createdAt 字段
  final bool enableUpdatedAt;    // 是否有 updatedAt 字段

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
  Future<List<T>> getAll();
  Future<List<T>> getAllFromDb();
  Future<T?> getFirstBy({required String fieldName, required dynamic value, bool tryCache = true, ModelTransaction? mtn});
  Future<T?> getFirstWith(String where, {List<Object?>? whereArgs, List<String>? columns, String? orderBy, ModelTransaction? mtn});
  Future<T?> getById(int id, {bool tryCache = true, ModelTransaction? mtn});
  Future<List<T>> getByIds(List<int> ids, {bool tryCache = true, ModelTransaction? mtn});
  Future<bool> exists(dynamic value, {required String fieldName, int? excludeId});
  Future<bool> existsWith(String where, {int? excludeId});
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
  UserService() : super('users', enableCache: true, enableSoftDelete: true);

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

---

### 3. 模型委托 (Model Delegate)

#### `MyModelDelegate<T extends IModel<T>>`

结合 ModelHelper 和响应式列表，提供列表操作和数据库同步。

```dart
class MyModelDelegate<T extends IModel<T>> {
  final ModelHelper<T>? service;
  final IMessageService? messageService;
  final RxList<T>? rxItems;
  final RxInt? rxTotal;

  // 插入到最前面
  Future<void> insert(T entity, {bool syncDb = true, bool showMessage = true, bool navBack = true});

  // 追加到最后
  Future<void> push(T entity, {bool syncDb = true, bool showMessage = true, bool navBack = true});

  // 更新记录
  Future<void> update(T entity, int index, {bool syncDb = true, bool showMessage = true, bool navBack = true});

  // 删除记录
  Future<int> remoteAt({required int index, String? title, bool syncDb = true, bool deleteConfirm = true, bool showMessage = true, bool navBack = true});

  // 根据 ID 删除
  Future<int> removeWithId({required int id, int? index, String? title, bool syncDb = true, bool deleteConfirm = true, bool showMessage = true, bool navBack = true});

  // 通用触发器（保存或删除）
  Future<void> trigger(T? entity, int index, {...});
}
```

---

### 4. 模型操作 (Model Action)

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

---

### 5. 查询构建器 (Query Builder)

```dart
class QueryBuilder<T> {
  QueryBuilder<T> where(String field, String operator, dynamic value);
  QueryBuilder<T> andWhere(String field, String operator, dynamic value);
  (String, List<Object?>) build();
}
```

---

## 工具类库 (Utils)

### 全局工具对象 `tu`

```dart

class _TUtils {
  const _TUtils();

  final path = const FilepathUtil();
  final file = const FileUtil();
  final colorMsg = const ColorMessageUtil();
  final data = const DataUtil();
  final date = const DatetimeUtil();
  final fn = const FnUtil();
  final get = const GetUtil();
  final number = const NumberUtil();
  final permission = const PermissionUtil();
  final url = const UrlUtil();
  final zip = const ZipUtil();
  final imagePicker = const ImagePickerUtil();

  /// 直接调用将可能无法测试，建议使用 getIFilePickerService()
  final filePicker = const FilePickerService();
  final device = const DeviceUtil();
  final context = const ContextUtil();
  final text = const TextUtil();
  final form = const FormHelperUtil();

  final api = const ApiUtil();
}

const tu = _TUtils();
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

#### 日期时间工具 (`DatetimeUtil`)

```dart
class DatetimeUtil {
  // 获取当前时间
  String getNowTime({String pattern = 'yyyy-MM-dd HH:mm:ss'});

  // 格式化日期
  String format({
    int timestamp = 0,
    DateTime? dateTime,
    String? iso8601,
    DateTimeFormat format = DateTimeFormat.ymdHms,
  });

  // 快捷格式化
  String formatYM({...});
  String formatYMD({...});
  String formatYMDHM({...});
  String formatYMDHMS({...});
  String formatWith(String format, DateTime datetime);

  // 解析日期
  DateTime? parse(dynamic dateStr, {bool nowIfEmpty = false, String? formatPattern});

  // 比较
  int compareTo(dynamic a, dynamic b);

  // 时间戳
  int timestamp(DateTime dt, {bool l10 = false, bool l13 = false});

  // 格式化分钟数
  String formatMinutes(int totalMinutes);
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

#### 文件选择 FilePickerService

内部引入了 [file_picker](https://pub.dev/packages/file_picker)

```dart
/// 选择多个文件
Future<List<PlatformFile>?> pickFiles({
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
/// 选择文件，并返回它们的路径 [suggestExtensions] 常见的文件类型
Future<List<String>> pickFilesPath({
  bool allowMultiple = true,
  List<String>? allowedExtensions,
  bool suggestExtensions = true,
});
/// 返回第1个选择文件的路径
Future<String?> pickFirstPath({List<String>? allowedExtensions});

/// 获取选择的文件，可以使用 FilepathUtil.getFileNames 来获取文件名
Future<List<File>> quickPickFiles({
  FileType type = FileType.any,
  List<String>? allowedExtensions,
  String? initialDirectory,
  bool allowMultiple = false,
});

// 这会打开一个原生文件选择对话框，只允许用户选择目录，而不是文件。
Future<String?> getDirectory();

/// 选择文件并读取文件内容
Future<String?> pickAndRead({
  FileType type = FileType.any,
  String? initialDirectory,
  List<String>? allowedExtensions,
});
```

#### 相册文件操作 FileUtil

内部引入了 [file_selector](https://pub.dev/packages/file_selector) 和 [flutter_image_gallery_saver](https://pub.dev/packages/flutter_image_gallery_saver)

```dart
/// 保存图片到用户相册
Future<void> saveImage({
  File? file,
  Uint8List? imageBytes,
  String? suggestedFileName,
});

/// 保存文件
Future<void> saveFile(String filePath);
Future<bool> exists(String filePath);

/// 异步计算给定文件的 MD5 哈希值
/// 返回一个 32 字符的十六进制字符串
Future<String> fileMd5(String filePath);

Future<String> getContent(String filePath) async;
```

#### 图片拍摄 ImagePickerUtil

内部引入了 [image_picker](https://pub.dev/packages/image_picker)]

* `Future<XFile?> pick({ ImagePickerSource source = ImagePickerSource.gallery,})` 选择/拍摄一个图片或视频；
* `Future<List<XFile>?> pickMultiple({ ImagePickerMultipleSource source = ImagePickerMultipleSource.image, })`
* `Future<String?> pickPath({ ImagePickerSource source = ImagePickerSource.gallery,})`
* `Future<List<String>> pickMultiplePath({ ImagePickerMultipleSource source = ImagePickerMultipleSource.image, })` 选择多份资源（默认图片），并返回路径

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

#### UrlUtil

* `bool hasAbsolutePath(String uri)`
* `bool isAbsoluteWebUri(String uriString)`
* `Uri concat(String host, String path)` 连接主机与路径， `[host]` 主机；`[path]` 路径
* `String host(String url)`
* `String? encodeQueryParameters(Map<String, String> params)` 编码 URL 查询参数
* `Future<bool> launch( String url, { String? title, LaunchMode? mode, Function()? error, })` 内部使用 [url_launcher](https://pub.dev/packages/url_launcher)

#### ZipUtil

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

### 路径 FilepathUtil

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

## 翻译系统 (Translation)

### `TranslationService`

支持多语言翻译，基于 GetX Translations。

**核心方法：**

```dart
class TranslationService extends Translations {
  Map<String, Map<String, String>> get keys;

  // 添加字典
  void addDict(Map<String, Map<String, String>> newKeys);

  // 添加翻译
  void addKeys(Map<String, String> newKeys, {String locale = 'zh_CN'});
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

## 混入类 (Mixins)

### `MixinTao996Service`

Service 混入类。

```dart
mixin MixinTao996Service {
  final IMessageService messageService = getIMessageService();
  final IDebugService debugService = getIDebugService();
}
```

**导航辅助函数：**

```dart
void goBackWithResult(dynamic result);
void goBack();
```

## 核心数据类型


### `ResourceLocation`

资源位置枚举。

```dart
enum ResourceLocation { local, network, assets, unknown }
```

### `ImagePickerSource`

图片选择源。

```dart
enum ImagePickerSource {
  camera,        // 拍照
  gallery,       // 相册
  galleryVideo,  // 从相册选择视频
  cameraVideo,   // 拍摄视频
  media,         // 选择图片和视频
}
```

### `DateTimeFormat`

日期时间格式。

```dart
enum DateTimeFormat {
  ym,          // 2025-01
  ymd,         // 2025-01-21
  ymdHm,       // 2025-01-21 10:30
  ymdHms,      // 2025-01-21 10:30:45
  ymdFile,     // 20250121
  ymdHmFile,   // 20250121-1030
  ymdHmsFile,  // 20250121-103045
}
```

### `KV<T>`

键值对类。

```dart
class KV<T> {
  final String label;
  final T value;

  KV({required this.label, required this.value});
}
```