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
abstract class IModel<T> {
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

  /// 将实例转换为 Map，通常用于 JSON 序列化
  // ========== 通用 toMap 实现 ==========
  // 负责将 IModel 的基础字段转换为 Map
  Map<String, dynamic> _baseToMap() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  String get createdAtText => createdAt?.toIso8601String() ?? '';
  String get updatedAtText => updatedAt?.toIso8601String() ?? '';
  String get deletedAtText => deletedAt?.toIso8601String() ?? '';

  // 抽象方法，强制子类实现其特有字段的 toMap 逻辑
  Map<String, dynamic> toObjectMap();

  // 最终的 toMap() 方法，合并基础字段和子类字段
  Map<String, dynamic> toMap() {
    return {..._baseToMap(), ...toObjectMap()};
  }

  // ========== 通用 fromMap 实现 ==========
  // 负责从 Map 中解析 IModel 的基础字段
  void fromBaseMap(Map<String, dynamic> map) {
    id = map['id'] as int? ?? 0;
    createdAt = _dateTimeParse(map['createdAt']);
    updatedAt = _dateTimeParse(map['updatedAt']);
    deletedAt = _dateTimeParse(map['deletedAt']);
  }

  // 抽象方法，强制子类实现其特有字段的 fromMap 逻辑
  T fromObjectMap(Map<String, dynamic> map);

  // 通用的工具方法
  static DateTime? _dateTimeParse(dynamic dt) {
    if (dt == null) return null;
    if (dt is String) return DateTime.parse(dt);
    if (dt is int) return DateTime.fromMillisecondsSinceEpoch(dt);
    return null;
  }
}

/*

class Credential extends IModel<Credential> {
  String name;
  String username;
  String authMethod;
  String password;
  String privateKey;
  String keyPassword;

  Credential({
    super.id,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
    required this.name,
    required this.username,
    required this.authMethod,
    required this.password,
    required this.privateKey,
    required this.keyPassword,
  });

  factory Credential.fromMap(Map<String, dynamic> map) {
    final m = Credential(
      name: '',
      username: '',
      authMethod: '',
      password: '',
      privateKey: '',
      keyPassword: '',
    );
    m.fromBaseMap(map);
    return m.fromObjectMap(map);
  }


  @override
  String toString() {
    return '''Credential{id: $id, name: $name, username: $username,
authMethod: $authMethod
password: $password,
keyPassword: $keyPassword, privateKey: $privateKey,
}''';
  }

  @override
  Credential fromObjectMap(Map<String, dynamic> map) {
    name = map['name'];
    username = map['username'];
    authMethod = map['authMethod'];
    password = map['password'];
    privateKey = map['privateKey'];
    keyPassword = map['keyPassword'];
    return this;
  }

  @override
  Map<String, dynamic> toObjectMap() {
    return {
      'name': name,
      'username': username,
      'authMethod': authMethod,
      'password': password,
      'privateKey': privateKey,
      'keyPassword': keyPassword,
    };
  }
}

 */
