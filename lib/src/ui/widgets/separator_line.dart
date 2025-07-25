import 'package:flutter/material.dart';


class MySeparatorLine extends StatelessWidget {
  const MySeparatorLine({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      color: Color(0xFFEEEEEE), // 使用 Flutter 提供的灰色
      thickness: 1.0, // 可选：设置分隔线的粗细
      indent: 16.0, // 可选：设置分隔线左侧的缩进
      endIndent: 60.0, // 可选：设置分隔线右侧的缩进
    );
  }
}