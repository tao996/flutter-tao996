import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 标签管理器
class TagsManager extends StatefulWidget {
  final List<String> values;
  final String? label;
  final String? hintText;
  final Function(List<String>)? onChanged; // 添加回调以便父组件感知变化

  const TagsManager({
    super.key,
    required this.values,
    this.onChanged,
    this.label,
    this.hintText,
  });

  @override
  State<TagsManager> createState() => _TagsManagerState();
}

class _TagsManagerState extends State<TagsManager> {
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
