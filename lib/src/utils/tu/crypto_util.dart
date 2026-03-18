import 'dart:convert';

import 'package:crypto/crypto.dart';

class CryptoUtil {
  const CryptoUtil();

  Future<String> generateMd5({
    String? input,
    Stream<List<int>>? inputStream,
  }) async {
    if (inputStream != null) {
      // 3. 将文件流通过 md5.bind(inputStream) 注入，计算哈希值
      final digest = await md5.bind(inputStream).first;

      // 4. 将 Digest 对象转换为十六进制字符串
      return digest.toString();
    } else if (input != null) {
      return md5Text(input);
    }
    return '';
  }

  String md5Text(String input) {
    // 1. 将字符串转为 UTF-8 字节流
    var bytes = utf8.encode(input);
    // 2. 计算 MD5
    var digest = md5.convert(bytes);
    // 3. 以十六进制字符串形式输出
    return digest.toString();
  }
}
