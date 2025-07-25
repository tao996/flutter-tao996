import 'dart:io';
import 'package:path_provider/path_provider.dart';

abstract class IPathService {
  /// 获取临时目录
  Future<Directory> getTemporaryDirectoryPath();
  /// 获取应用目录
  Future<Directory> getApplicationDocumentsDirectoryPath();
}

class PathService implements IPathService {
  @override
  Future<Directory> getTemporaryDirectoryPath() async {
    return await getTemporaryDirectory();
  }

  @override
  Future<Directory> getApplicationDocumentsDirectoryPath() async {
    return await getApplicationDocumentsDirectory();
  }
}
