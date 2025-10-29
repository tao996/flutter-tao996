import 'package:flutter/material.dart';
import 'package:tao996/tao996.dart';

class MyText {
  static Widget h1(String text) {
    return Text(text, style: getTextTheme().displayLarge);
  }

  static Widget h2(String text) {
    return Text(text, style: getTextTheme().headlineMedium);
  }

  static Widget h3(String text) {
    return Text(text, style: getTextTheme().titleLarge);
  }

  static Widget h4(String text) {
    return Text(text, style: getTextTheme().titleMedium);
  }

  static Widget h5(
    String text, {
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
  }) {
    return _text(
      text,
      style: getTextTheme().bodyLarge,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
    );
  }

  static Widget h6(String text) {
    return Text(text, style: getTextTheme().bodyMedium);
  }

  static Widget _text(
    String text, {
    TextStyle? style,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
  }) {
    if (style != null) {
      style = style.copyWith(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
      );
    }
    return Text(text, style: style);
  }

  static Widget groupText(
    String title, {
    double horizontal = 18,
    double vertical = 10,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: Text(title, style: getTextTheme().bodyMedium),
    );
  }

  static Widget warning(String text) {
    return Text(
      text,
      style: TextStyle(
        color: getColorScheme().error,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static Widget info(String text) {
    return Text(
      text,
      style: TextStyle(color: MyColor.info(), fontWeight: FontWeight.bold),
    );
  }

  static Widget listTitle(String title, {String? subTitle, bool bold = true}) {
    final Color primaryTextColor = getColorScheme().onSurface;
    final Color subduedTextColor = MyColor.text(
      0.6,
    ); // 模拟 Colors.grey[600] 的柔和效果

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: (bold ? TextStyle(fontWeight: FontWeight.bold) : null)
              ?.copyWith(
                color: primaryTextColor, // 替换 Colors.black
              ),
        ),
        if (subTitle != null && subTitle.isNotEmpty)
          Text(
            subTitle,
            style: TextStyle(
              fontSize: 12,
              color: subduedTextColor, // 替换 Colors.grey[600]
            ),
          ),
      ],
    );
  }

  static Widget labelText(
    String label,
    String content, {
    String? helperText,
    // bool border = true,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        // enabled: border,
        // border: border ? null : InputBorder.none,
        // enabledBorder: border ? null : InputBorder.none,
        helperText: helperText,
        isDense: true,
      ),
      child: Text(content),
    );
  }

  /// 加粗显示
  static Widget bold(String text) {
    return Text(text, style: TextStyle(fontWeight: FontWeight.bold));
  }

  static Widget groupTitle({required String title, IconData? icon}) {
    return _SectionHeader(title: title, icon: icon);
  }
}

/// 一个美观的区块/分组标题组件
/// 用于取代简单的 MyText.h5 + Divider 的组合
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;

  const _SectionHeader({required this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    final child = MyText.h5(
      title,
      fontWeight: FontWeight.w700, // 更粗的字体
      color: Colors.blueGrey[800],
    );
    if (icon == null) {
      return child;
    }
    // 使用 Row 组合图标和文本
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. 图标
        Icon(icon, size: 18, color: Colors.blue[700]),
        MyLayout.width8(), // 间距
        // 2. 标题文本
        child,
      ],
    );

    // return Padding(
    //   padding: const EdgeInsets.fromLTRB(4, 12, 4, 10),
    //   child: content,
    // );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 顶部留白和内边距
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 12),
          child: content,
        ),
        // 底部细分隔线
        Container(height: 1.0, color: Colors.grey[300]),
      ],
    );
  }
}
