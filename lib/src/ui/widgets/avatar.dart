import 'dart:io';

import 'package:flutter/material.dart';

class MyAvatar extends StatelessWidget {
  /// 头像的本地路径
  final String? logoPath;

  /// 名称，会将第1个字符作为头像显示
  final String? name;

  /// 是否使用本地头像，默认为 true
  final bool useLogo;

  /// 显示为 18
  final double radius;

  /// 默认为 Icons.person
  final IconData? icon;

  const MyAvatar({
    super.key,
    this.useLogo = true,
    this.logoPath,
    this.name,
    this.icon,
    this.radius = 18,
  });

  @override
  Widget build(BuildContext context) {
    if (useLogo &&
        logoPath != null &&
        logoPath!.isNotEmpty &&
        File(logoPath!).existsSync()) {
      try {
        return CircleAvatar(
          backgroundImage: FileImage(File(logoPath!)),
          radius: radius,
        );
      } catch (error) {
        return CircleAvatar(radius: radius, child: Icon(icon ?? Icons.rss_feed_outlined));
      }
    }
    if (name != null && name!.isNotEmpty) {
      return CircleAvatar(radius: radius, child: Text(name![0]));
    }
    return CircleAvatar(radius: radius, child: Icon(icon ?? Icons.rss_feed_outlined));
  }
}
