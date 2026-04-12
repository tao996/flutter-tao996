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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(720),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withAlpha(10),
                    spreadRadius: 10,
                    blurRadius: 10,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                args.logoAssets,
                height: Get.mediaQuery.size.width / 3,
              ),
            ),
            Text(args.appTitle, style: const TextStyle(fontSize: 36)),

            if (args.appInfo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
                child: Text(
                  args.appInfo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20),
                ),
              ),

            const SizedBox(height: 20),
            if (args.version.isNotEmpty)
              ListTile(
                title: Text('appVersion'.tr),
                trailing: Text(args.version + (kDebugMode ? ' (Debug)' : '')),
              ),

            if (args.copyright.isNotEmpty)
              ListTile(
                title: Text('appCopyright'.tr),
                trailing: Text(args.copyright),
              ),
            if (args.homeUrl.isNotEmpty)
              ListTile(
                title: Text('appWebSite'.tr),
                subtitle: Text(args.homeUrl),
                onTap: () async {
                  await c.contactService.open(args.homeUrl);
                },
                trailing: const Icon(Icons.keyboard_arrow_right_outlined),
              ),
            if (args.cnDocs.isNotEmpty)
              ListTile(
                title: const Text('中文文档'),
                subtitle: Text(args.cnDocs),
                onTap: () async {
                  await c.contactService.open(args.cnDocs);
                },
                trailing: const Icon(Icons.keyboard_arrow_right_outlined),
              ),
            if (args.enDocs.isNotEmpty)
              ListTile(
                title: const Text('En Docs'),
                subtitle: Text(args.enDocs),
                onTap: () async {
                  await c.contactService.open(args.enDocs);
                },
                trailing: const Icon(Icons.keyboard_arrow_right_outlined),
              ),

            if (args.termsOfService.isNotEmpty)
              ListTile(
                title: Text('termsOfService'.tr),
                subtitle: Text(args.termsOfService),
                onTap: () async {
                  await c.contactService.open(args.termsOfService);
                },
                trailing: const Icon(Icons.keyboard_arrow_right_outlined),
              ),
            if (args.privacyPolicy.isNotEmpty)
              ListTile(
                title: Text('privacyPolicy'.tr),
                subtitle: Text(args.privacyPolicy),
                onTap: () async {
                  await c.contactService.open(args.privacyPolicy);
                },
                trailing: const Icon(Icons.keyboard_arrow_right_outlined),
              ),

            const SizedBox(height: 10),

            if (args.email.isNotEmpty)
              ListTile(
                title: Text('Email'),
                subtitle: Text(args.email),
                trailing: const Icon(Icons.send_outlined),
                onTap: () async {
                  await c.contactService.sendEmail(args.email);
                },
              ),

            if (args.github.isNotEmpty)
              ListTile(
                title: Text('Github'),
                subtitle: Text(args.github),
                trailing: const Icon(Icons.keyboard_arrow_right_outlined),
                onTap: () async {
                  await c.contactService.open(
                    args.github,
                    platform: ContactPlatform.github,
                  );
                },
              ),
            if (args.wechat.isNotEmpty)
              ListTile(
                title: Text('微信 Wechat'),
                subtitle: Text(args.wechat),
                trailing: const Icon(Icons.copy_outlined),
                onTap: () async {
                  await c.contactService.copy(args.wechat);
                },
              ),

            if (args.weibo.isNotEmpty)
              ListTile(
                title: Text('微博 Weibo'),
                subtitle: Text(args.weibo),
                trailing: const Icon(Icons.copy_outlined),
                onTap: () async {
                  await c.contactService.copy(args.weibo);
                },
              ),

            if (args.facebook.isNotEmpty)
              ListTile(
                title: Text('Facebook'),
                subtitle: Text(args.facebook),
                trailing: const Icon(Icons.keyboard_arrow_right_outlined),
                onTap: () async {
                  await c.contactService.open(
                    args.facebook,
                    platform: ContactPlatform.facebook,
                  );
                },
              ),

            if (args.twitter.isNotEmpty)
              ListTile(
                title: Text('Twitter'),
                subtitle: Text(args.twitter),
                trailing: const Icon(Icons.keyboard_arrow_right_outlined),
                onTap: () async {
                  await c.contactService.open(
                    args.twitter,
                    platform: ContactPlatform.twitter,
                  );
                },
              ),
            if (args.telegram.isNotEmpty)
              ListTile(
                title: const Text('Telegram'),
                subtitle: Text(args.telegram),
                trailing: const Icon(Icons.keyboard_arrow_right_outlined),
                onTap: () async {
                  await c.contactService.open(
                    args.telegram,
                    platform: ContactPlatform.telegram,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
