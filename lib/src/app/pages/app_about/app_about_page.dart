import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/app.dart';
import 'package:tao996/src/app/pages/app_about/app_about_controller.dart';
import 'package:tao996/tao996.dart';

class AppAboutArguments {
  final String logoAssets;
  final String appTitle;
  final String appInfo;
  final String version;
  final String homeUrl;
  final String cnDocs;
  final String enDocs;
  final String termsOfService;
  final String privacyPolicy;
  final String copyright;
  // 联系方式
  final String email;
  final String github;
  final String wechat;
  final String weibo;
  final String facebook;
  final String twitter;
  final String telegram;

  AppAboutArguments({
    this.logoAssets = 'assets/logo.jpg',
    required this.appTitle,
    required this.appInfo,
    required this.version,
    required this.homeUrl,
    required this.cnDocs,
    required this.enDocs,
    required this.termsOfService,
    required this.privacyPolicy,
    required this.copyright, // '© 2024-${DateTime.now().year} boyu IT.'
    required this.email,
    required this.github,
    required this.wechat,
    required this.weibo,
    required this.facebook,
    required this.twitter,
    required this.telegram,
  });
}

class AppAboutPage extends StatelessWidget {
  final AppAboutArguments args;
  final c = Get.put(AppAboutController());

  AppAboutPage(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      singleChildScrollView: true,
      appBar: AppBar(title: Text('aboutUs'.tr)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. 头部身份区
            _buildHeader(context),
            const SizedBox(height: 24),

            // 2. 资源分组
            _buildGroupTitle('appWebSite'.tr),
            Card(
              child: Column(
                children: [
                  if (args.homeUrl.isNotEmpty)
                    _buildListTile(
                      context,
                      'appWebSite'.tr,
                      args.homeUrl,
                      Icons.language,
                      onTap: () => c.contactService.open(args.homeUrl),
                    ),
                  if (args.cnDocs.isNotEmpty)
                    _buildListTile(
                      context,
                      '中文文档',
                      args.cnDocs,
                      Icons.description_outlined,
                      onTap: () => c.contactService.open(args.cnDocs),
                    ),
                  if (args.enDocs.isNotEmpty)
                    _buildListTile(
                      context,
                      'En Docs',
                      args.enDocs,
                      Icons.translate,
                      onTap: () => c.contactService.open(args.enDocs),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. 法律条款
            _buildGroupTitle('termsOfService'.tr),
            Card(
              child: Column(
                children: [
                  if (args.termsOfService.isNotEmpty)
                    _buildListTile(
                      context,
                      'termsOfService'.tr,
                      null,
                      Icons.assignment_outlined,
                      onTap: () => c.contactService.open(args.termsOfService),
                    ),
                  if (args.privacyPolicy.isNotEmpty)
                    _buildListTile(
                      context,
                      'privacyPolicy'.tr,
                      null,
                      Icons.privacy_tip_outlined,
                      onTap: () => c.contactService.open(args.privacyPolicy),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. 联系我们
            _buildGroupTitle('Contact & Social'),
            Card(
              child: Column(
                children: [
                  if (args.email.isNotEmpty)
                    _buildContactTile(
                      context,
                      'Email',
                      Icons.email_outlined,
                      onTap: () => c.contactService.sendEmail(args.email),
                    ),
                  if (args.github.isNotEmpty)
                    _buildContactTile(
                      context,
                      'Github',
                      'packages/tao996/assets/icons/github.svg',
                      onTap: () => c.contactService.open(
                        args.github,
                        platform: ContactPlatform.github,
                      ),
                    ),
                  if (args.wechat.isNotEmpty)
                    _buildContactTile(
                      context,
                      '微信 Wechat',
                      'packages/tao996/assets/icons/wechat.svg',
                      isCopy: true,
                      onTap: () => c.contactService.copy(args.wechat),
                    ),
                  if (args.weibo.isNotEmpty)
                    _buildContactTile(
                      context,
                      '微博 Weibo',
                      'packages/tao996/assets/icons/weibo.svg',
                      onTap: () => c.contactService.copy(args.weibo),
                    ),
                  if (args.facebook.isNotEmpty)
                    _buildContactTile(
                      context,
                      'Facebook',
                      'packages/tao996/assets/icons/facebook.svg',
                      onTap: () => c.contactService.open(
                        args.facebook,
                        platform: ContactPlatform.facebook,
                      ),
                    ),
                  if (args.twitter.isNotEmpty)
                    _buildContactTile(
                      context,
                      'Twitter',
                      'packages/tao996/assets/icons/x-twitter.svg',
                      onTap: () => c.contactService.open(
                        args.twitter,
                        platform: ContactPlatform.twitter,
                      ),
                    ),

                  if (args.telegram.isNotEmpty)
                    _buildContactTile(
                      context,
                      'Telegram',
                      'packages/tao996/assets/icons/telegram.svg',
                      onTap: () => c.contactService.open(
                        args.telegram,
                        platform: ContactPlatform.telegram,
                      ),
                    ),
                ],
              ),
            ),

            // 5. 页脚版权
            const SizedBox(height: 48),
            if (args.copyright.isNotEmpty)
              Opacity(
                opacity: 0.5,
                child: Text(
                  args.copyright,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // 构建头部展示
  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 24, bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24), // 稍微方圆一点看起来更现代
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                spreadRadius: 8,
                blurRadius: 15,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(args.logoAssets, height: 80, width: 80),
        ),
        Text(
          args.appTitle,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Version ${args.version}${kDebugMode ? ' (Debug)' : ''}',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        if (args.appInfo.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 24, right: 24),
            child: Text(
              args.appInfo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
      ],
    );
  }

  // 构建分组标题
  Widget _buildGroupTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  // 通用列表项
  Widget _buildListTile(
    BuildContext context,
    String title,
    String? subtitle,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      subtitle: subtitle != null
          ? Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis)
          : null,
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  // 联系方式专用列表项
  Widget _buildContactTile(
    BuildContext context,
    String title,
    dynamic iconOrSvg, {
    required VoidCallback onTap,
    bool isCopy = false,
  }) {
    return ListTile(
      leading: iconOrSvg is IconData
          ? Icon(iconOrSvg, size: 22)
          : MyIconSvg(iconOrSvg, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: Icon(
        isCopy ? Icons.copy_outlined : Icons.chevron_right,
        size: 18,
      ),
      onTap: onTap,
    );
  }
}
