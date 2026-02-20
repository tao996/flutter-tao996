import 'package:flutter/material.dart';
import 'package:tao996/tao996.dart';

class MyText {
  /// H1 -> Display: 用于极其醒目的数字或超大标题
  static Widget h1(
    String text, {
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    BuildContext? context,
  }) => _build(
    text,
    tu.textTheme.displayMedium,
    color,
    fontSize,
    fontWeight ?? FontWeight.bold,
  );

  /// H2 -> Headline: 用于页面主标题
  static Widget h2(
    String text, {
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    BuildContext? context,
  }) => _build(
    text,
    tu.textTheme.headlineSmall,
    color,
    fontSize,
    fontWeight ?? FontWeight.bold,
  );

  /// H3 -> TitleLarge: 用于大卡片标题
  static Widget h3(
    String text, {
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    BuildContext? context,
  }) => _build(
    text,
    tu.textTheme.titleLarge,
    color,
    fontSize,
    fontWeight ?? FontWeight.w600,
  );

  /// H4 -> TitleMedium: 用于标准列表/分组标题
  static Widget h4(
    String text, {
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    BuildContext? context,
  }) => _build(
    text,
    tu.textTheme.titleMedium,
    color,
    fontSize,
    fontWeight ?? FontWeight.w600,
  );

  /// H5 -> BodyLarge: 用于正文强调
  static Widget h5(
    String text, {
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    BuildContext? context,
  }) => _build(text, tu.textTheme.bodyLarge, color, fontSize, fontWeight);

  /// H6 -> BodyMedium: 用于次要正文/默认文字
  static Widget h6(
    String text, {
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    BuildContext? context,
  }) => _build(text, tu.textTheme.bodyMedium, color, fontSize, fontWeight);

  /// 内部通用构建方法
  static Widget _build(
    String text,
    TextStyle? baseStyle,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  ) {
    return Text(
      text,
      style: baseStyle?.copyWith(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }

  /// 专门用于描述文字（灰色、小字）
  static Widget desc(
    String text, {
    BuildContext? context,
    TextAlign? textAlign,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      style: tu.textTheme.bodySmall?.copyWith(color: Colors.grey),
    );
  }

  /// 价格或数字显示（通常需要等宽字体或特殊颜色）
  static Widget price(
    double value, {
    Color color = Colors.red,
    bool bold = true,
  }) {
    return Text(
      value.toStringAsFixed(2),
      style: TextStyle(
        color: color,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        fontFamily: 'monospace', // 数字建议等宽
      ),
    );
  }

  /// 带有状态感的文字
  static Widget status(
    String text, {
    required Color color,
    bool filled = false,
  }) {
    if (!filled) {
      return Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static Widget groupText(
    String title, {
    double horizontal = 18,
    double vertical = 10,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  static Widget warning(String text, {BuildContext? context}) {
    return Text(
      text,
      style: TextStyle(
        color: tu.colorScheme.error,
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

  static Widget labelText(
    String label,
    String content, {
    String? helperText,
    // bool border = true,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        fillColor: Colors.grey[100],
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

  /// 分组标题
  static Widget sectionTitle(
    String title, {
    IconData? iconData,
    String? subTitle,
    Widget? trailing,
    BuildContext? context,
  }) {
    if (subTitle == null && trailing == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            if (iconData != null)
              Icon(iconData, size: 20, color: tu.colorScheme.primary),
            if (iconData != null) const SizedBox(width: 8),
            Text(
              title,
              style: tu.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2, // 稍微拉开字间距更有品质感
              ),
            ),
          ],
        ),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center, // 确保垂直居中
      children: <Widget>[
        if (iconData != null) ...[
          Icon(iconData, size: 24),
          const SizedBox(width: 16),
        ], // 间距
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: tu.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: tu.colorScheme.primary,
                ),
              ),
              if (subTitle != null && subTitle.isNotEmpty)
                Text(
                  subTitle,
                  style: TextStyle(fontSize: 12, color: MyColor.text(0.6)),
                ),
            ],
          ),
        ),

        // Trailing (右侧图标/Widget)
        ?trailing,
      ],
    );
  }
}
