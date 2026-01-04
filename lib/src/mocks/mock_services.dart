// 将下面的代码复制到你的 test 目录下
// 使用  flutter pub run build_runner build 来更新
// dart run build_runner build --delete-conflicting-outputs

import 'package:mockito/annotations.dart';
import 'package:tao996/tao996.dart';

// 告诉 build_runner 为 AbstractExecutor 生成一个 Mock 类
@GenerateNiceMocks([MockSpec<IDatabaseService>()])
void main() {}
