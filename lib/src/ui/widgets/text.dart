import 'package:flutter/material.dart';

class MyText {
  static TextTheme getTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.textTheme;
  }

  static Widget h1(BuildContext context, String text) {
    return Text(text, style: getTheme(context).displayLarge);
  }

  static Widget h2(BuildContext context, String text) {
    return Text(text, style: getTheme(context).headlineMedium);
  }

  static Widget h3(BuildContext context, String text) {
    return Text(text, style: getTheme(context).titleLarge);
  }

  static Widget h4(BuildContext context, String text) {
    return Text(text, style: getTheme(context).titleMedium);
  }

  static Widget h5(BuildContext context, String text) {
    return Text(text, style: getTheme(context).bodyLarge);
  }

  static Widget h6(BuildContext context, String text) {
    return Text(text, style: getTheme(context).bodyMedium);
  }

  static Widget groupText(
    String title, {
    double horizontal = 18,
    double vertical = 10,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: Text(title),
    );
  }

  static Widget warning(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
    );
  }

  static Widget info(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold),
    );
  }

  static Widget listTitle(String title, {String? subTitle, bool bold = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: bold
              ? TextStyle(fontWeight: FontWeight.bold, color: Colors.black)
              : null,
        ),
        if (subTitle != null && subTitle.isNotEmpty)
          Text(
            subTitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
      ],
    );
  }

  static Widget helperText(String text) {
    return CustomHelperText(text);
  }

  static Widget labelText(String label, String content, {String? helperText}) {
    return TextFormField(
      readOnly: true,
      initialValue: content,
      style: TextStyle(color: Colors.grey[600]),
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}

/// 自定义辅助文本组件，类似 InputDecoration 的 helperText 效果
/// 可在输入框下方显示说明文字，支持自定义样式和交互
class CustomHelperText extends StatelessWidget {
  /// 辅助文本内容
  final String text;

  /// 文本样式（默认使用主题中的提示文本样式）
  final TextStyle? style;

  /// 文本颜色（优先级高于 style 中的颜色）
  final Color? color;

  /// 内边距（默认与 InputDecoration 的 helperText 保持一致）
  final EdgeInsetsGeometry? padding;

  /// 文本对齐方式（默认左对齐）
  final TextAlign textAlign;

  /// 最大行数（默认1行，超出显示省略号）
  final int maxLines;

  /// 点击事件（可选，支持交互）
  final VoidCallback? onTap;

  const CustomHelperText(
    this.text, {
    super.key,
    this.style,
    this.color,
    this.padding,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 获取主题中的提示文本样式（与 InputDecoration 的 helperText 保持一致）
    final ThemeData theme = Theme.of(context);
    final defaultStyle =
        theme.inputDecorationTheme.helperStyle ??
        theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withAlpha(210), // 默认半透明显示
        );

    // 合并用户自定义样式与默认样式
    final textStyle = style?.merge(defaultStyle) ?? defaultStyle;

    return Padding(
      // 默认内边距：左12，上4，与原生 helperText 一致
      padding: padding ?? const EdgeInsets.fromLTRB(16, 4, 12, 0),
      child: InkWell(
        // 如果有点击事件，添加水波纹效果
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Text(
          text,
          style: textStyle?.copyWith(
            color: color, // 覆盖颜色（如果用户指定）
          ),
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
