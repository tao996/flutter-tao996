import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 定义一个新的可复用 Widget 来实现伪输入框效果
class FakeDateInput extends StatefulWidget {
  final String labelText;
  final String? hintText;
  final DateTime? initialDate;

  // 修改回调函数，使其可以接受 null，表示清除日期
  final Function(DateTime?) onDateSelected;

  const FakeDateInput({
    super.key,
    required this.labelText,
    this.hintText,
    this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<FakeDateInput> createState() => _FakeDateInputState();
}

class _FakeDateInputState extends State<FakeDateInput> {
  // 内部状态：存储当前选中的日期
  late DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  // 格式化日期显示（使用 padLeft 确保两位数）
  String get _formattedDate {
    if (_selectedDate == null) {
      return widget.hintText ?? 'dateHint'.tr;
    }
    final year = _selectedDate!.year;
    final month = _selectedDate!.month.toString().padLeft(2, '0');
    final day = _selectedDate!.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  // 核心方法：显示日期选择器
  Future<void> _selectDate(BuildContext context) async {
    final initialDate = _selectedDate ?? DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      // 1. 更新内部状态
      setState(() {
        _selectedDate = picked;
      });
      // 2. 将选择的日期发送给外部回调
      widget.onDateSelected(picked);
    }
  }

  // 新增：清除日期的逻辑
  void _clearDate() {
    setState(() {
      _selectedDate = null; // 清除内部状态
    });
    widget.onDateSelected(null); // 通知外部日期已清除
  }

  // 构建动态的后缀图标 Widget
  Widget _buildSuffixIcon() {
    return Row(
      // 确保 Row 只占用其子 Widget 所需的最小空间
      mainAxisSize: MainAxisSize.min,
      children: [
        // 只有当日期不为空时才显示清除按钮
        if (_selectedDate != null)
          IconButton(
            icon: const Icon(Icons.clear, size: 20),
            onPressed: _clearDate,
          ),

        // 日历图标，始终显示
        IconButton(
          icon: const Icon(Icons.calendar_today, size: 20),
          onPressed: () => _selectDate(context), // 点击日历图标也打开选择器
        ),
        const SizedBox(width: 4), // 留出一点边距
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasDate = _selectedDate != null;

    // GestureDetector 捕获点击事件
    return GestureDetector(
      // 点击整个区域都可以打开日期选择器
      onTap: () => _selectDate(context),

      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          // 使用动态的 _buildSuffixIcon 方法
          suffixIcon: _buildSuffixIcon(),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
        ),

        child: Text(
          _formattedDate,
          style: TextStyle(
            // 如果没有日期，使用 HintText 的颜色
            color: hasDate
                ? Theme.of(context).textTheme.titleMedium?.color
                : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// 外部调用示例
// ==========================================================
//
// class DemoPage extends StatefulWidget {
//   const DemoPage({super.key});
//
//   @override
//   State<DemoPage> createState() => _DemoPageState();
// }
//
// class _DemoPageState extends State<DemoPage> {
//   DateTime? birthDate;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('带清除按钮的日期选择器')),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           children: [
//             FakeDateInput(
//               labelText: '出生日期',
//               initialDate: birthDate,
//               // 注意：onDateSelected 现在接受 DateTime?
//               onDateSelected: (date) {
//                 setState(() {
//                   birthDate = date;
//                 });
//                 print('外部接收到的日期: $date');
//               },
//             ),
//             const SizedBox(height: 20),
//             Text('最终选中的日期 (外部状态): ${birthDate?.toLocal().toString().split(' ')[0] ?? '未选择'}'),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// void main() {
//   runApp(const MaterialApp(home: DemoPage()));
// }
