import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/svg.dart';


class AppContactService {
  final debugSer = getIDebugService();
  final messageSer = getIMessageService();

  Future<void> sendEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: UrlUtil.encodeQueryParameters(<String, String>{
        'subject': '关于应用 ${'appTitle'.tr} 的疑问',
      }),
    );
    // 尝试打开 URL
    try {
      await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
    } catch (error, stackTrace) {
      debugSer.exception(error, stackTrace, errorMessage: '打开邮件时发生错误');
    }
  }

  Future<void> copy(String account) async {
    Clipboard.setData(ClipboardData(text: account));
    messageSer.success('Copy success'.tr);
  }

  /// 尝试打开 URL
  ///
  /// [account] 账号或者链接，如果是账号，则 [platform] 必须提供
  Future<void> open(String account, {String? platform}) async {
    String url;
    if (account.isEmpty) {
      messageSer.error('account is empty');
      return;
    }
    if (account.startsWith('https')) {
      url = account;
    } else {
      if (platform == 'facebook') {
        url = facebookUrl(account);
      } else if ('twitter' == platform) {
        url = twitterUrl(account);
      } else if ('github' == platform) {
        url = githubUrl(account);
      } else {
        messageSer.error('platform is not supported');
        return;
      }
    }
    UrlUtil.launch(url, title: platform);
  }

  String facebookUrl(String account) {
    return 'https://www.facebook.com/$account';
  }

  String twitterUrl(String account) {
    return 'https://twitter.com/$account';
  }

  String githubUrl(String account) {
    return 'https://github.com/$account';
  }

  Widget weiboIcon() {
    return SvgPicture.asset(
      'assets/icons/weibo.svg', // 确保路径正确
      width: 30,
      height: 30,
      colorFilter: ColorFilter.mode(Colors.red, BlendMode.srcIn), // 可以设置颜色
    );
  }

  Widget twitterIcon() {
    return SvgPicture.asset(
      'assets/icons/twitter.svg', // 确保路径正确
      width: 30,
      height: 30,
    );
  }

  Widget facebookIcon() {
    return Icon(Icons.facebook, color: Colors.blue, size: 30);
  }

  Widget wechatIcon() {
    return Icon(Icons.wechat, color: Colors.green, size: 30);
  }

  /// 社交组件
  ///
  /// [account] 账号或者链接
  Widget socialCard({
    required String account,
    required String platform,
    bool copyable = true,
  }) {
    Widget icon;
    switch (platform) {
      case 'twitter':
        icon = twitterIcon();
        break;
      case 'facebook':
        icon = facebookIcon();
        break;
      case 'wechat':
        icon = wechatIcon();
        break;
      case 'weibo':
        icon = weiboIcon();
        break;
      default:
        icon = Icon(Icons.link, color: Colors.grey, size: 30);
        break;
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: ListTile(
        leading: icon,
        title: Text(
          platform.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(account),
        trailing:
        copyable
            ? const Icon(Icons.copy, color: Colors.blueGrey)
            : const Icon(Icons.open_in_new, color: Colors.blue),
        onTap:
        account.isEmpty
            ? null
            : () async {
          if (account.isEmpty) {
            messageSer.error('account is empty'.tr);
            return;
          }
          if (copyable) {
            copy(account);
          } else {
            open(account, platform: platform);
          }
        },
      ),
    );
  }
}
