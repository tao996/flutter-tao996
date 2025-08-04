import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../tao996.dart';

class UrlUtil {
  /// 检查一个给定的字符串是否可以被解析成一个有效的 URI，并且这个 URI 具有一个绝对路径
  /// 绝对路径通常以 / 开始，表示从根目录开始的完整路径。例如，/path/to/resource 是一个绝对路径。
  static bool hasAbsolutePath(String uri) {
    return Uri.tryParse(uri)?.hasAbsolutePath ?? false;
  }

  /// 检查 uri 是否能成功解析，并且有 scheme (如 http, https) 和 host
  static bool isAbsoluteWebUri(String uriString) {
    final uri = Uri.tryParse(uriString);
    return uri != null && uri.hasScheme && uri.hasAuthority;
  }

  static Uri concat(String host, String url) {
    return Uri.parse(host).resolveUri(Uri.parse(url));
  }

  static String host(String url) {
    return Uri.parse(url).host;
  }

  /// 辅助函数，用于编码 URL 查询参数
  /// 因为 Uri 构造函数的 queryParameters 参数会将 Map 值进行自动编码
  /// 但对于 mailto: 链接，其主题和正文部分需要手动编码
  static String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  static Future<bool> launch(
    String url, {
    String? title,
    LaunchMode? mode,
    Function()? error,
  }) async {
    if (url.isEmpty) {
      if (error != null) {
        error();
      } else {
        getIMessageService().error(
          'urlIsEmpty'.trParams({'title': title ?? 'url'}),
        );
      }
      return false;
    }
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: mode ?? LaunchMode.platformDefault);
      return true;
    } else {
      if (error != null) {
        error();
      } else {
        getIMessageService().error(
          'openUrlFailed'.trParams({'title': title ?? 'url'}),
        );
      }
      return false;
    }
  }
}
