import 'package:tao996/tao996.dart';
import 'package:flutter_test/flutter_test.dart';

class User extends IModel<User> {
  final String name;

  User({required super.id, required this.name});

  @override
  User fromMap(Map<String, dynamic> map) {
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toMap() {
    throw UnimplementedError();
  }
}

// 模拟 Service
class MockUserService extends ModelHelper<User> {
  MockUserService(super.tableName);

  // 可以在这里模拟数据库操作返回值
  @override
  Future<int> deleteById(int id, {ModelTransaction? mtn}) async => 1;

  @override
  Future<User> insert(User entity, {ModelTransaction? mtn}) async =>
      entity..id = 999;

  @override
  Future<int> update(
    User entity, {
    List<String>? columns,
    ModelTransaction? mtn,
  }) async => 1;

  @override
  User fromMap(Map<String, dynamic> map) {
    throw UnimplementedError();
  }
}
