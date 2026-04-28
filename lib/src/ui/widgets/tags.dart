import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 标签管理器
class MyTagsManager extends StatefulWidget {
  final List<String> values;
  final String? label;
  final String? hintText;
  final Function(List<String>)? onChanged; // 添加回调以便父组件感知变化

  const MyTagsManager({
    super.key,
    required this.values,
    this.onChanged,
    this.label,
    this.hintText,
  });

  @override
  State<MyTagsManager> createState() => _MyTagsManagerState();
}

class _MyTagsManagerState extends State<MyTagsManager> {
  late List<String> items;

  @override
  void initState() {
    super.initState();
    items = List.from(widget.values);
  }

  // 弹出添加对话框
  void _showAddDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.label ?? 'add'.tr),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: widget.hintText),
          onSubmitted: (val) => _addTag(controller.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () => _addTag(controller.text),
            child: Text('confirm'.tr),
          ),
        ],
      ),
    );
  }

  void _addTag(String text) {
    if (text.trim().isNotEmpty) {
      setState(() {
        items.add(text.trim());
      });
      widget.onChanged?.call(items);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0, // 标签之间的水平间距
      runSpacing: 4.0, // 行与行之间的垂直间距
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // 渲染现有标签
        ...items.asMap().entries.map((entry) {
          int index = entry.key;
          String label = entry.value;
          return InputChip(
            label: Text(label),
            onDeleted: () {
              setState(() {
                items.removeAt(index);
              });
              widget.onChanged?.call(items);
            },
            deleteIcon: const Icon(Icons.cancel, size: 18),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        }),

        // 最后的添加按钮
        ActionChip(
          avatar: const Icon(Icons.add, size: 18),
          label: Text('add'.tr),
          onPressed: _showAddDialog,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primaryContainer.withAlpha(75),
        ),
      ],
    );
  }
}

// Widget tagsWrap(List<String> items) {
//   return Wrap(
//     spacing: 8.0, // 标签之间的水平间距
//     runSpacing: 4.0, // 行与行之间的垂直间距
//     crossAxisAlignment: WrapCrossAlignment.center,
//     children: [
//       // 渲染现有标签
//       ...items.asMap().entries.map((entry) {
//         int index = entry.key;
//         String label = entry.value;
//         return InputChip(
//           label: Text(label),
//           onPressed: () {},
//           materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//         );
//       }),
//     ],
//   );
// }
class MyTag {
  /// 主色
  static Widget primary(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        // 取主题主色的 10% 透明度作为背景
        color: Theme.of(context).colorScheme.primary.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary, // 文字使用主色，保证可读性
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 灰度“元数据”标签 , 如果你有很多标签，且不希望它们抢占用户视觉焦点（比如显示时间、创建人），使用灰色背景会更高级。
  static Widget gray(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest, // 使用 Material 3 推荐的背景灰
        borderRadius: BorderRadius.circular(16), // 更圆润的边角
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
      ),
    );
  }

  /// 警示/高亮标签, 用于“错误”、“已过期”或“重要”提示。
  static Widget highlight(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer, // 自动适配深/浅色模式
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onErrorContainer,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 多个使用时，需要套在 wrap 里面
  static Widget wrap(List<Widget> tags) {
    return Wrap(
      spacing: 8.0, // 标签之间的水平间距
      runSpacing: 4.0, // 行与行之间的垂直间距
      crossAxisAlignment: WrapCrossAlignment.start,
      children: tags,
    );
  }
}
