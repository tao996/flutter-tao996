import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/src/const/color.dart';

class FakeDatetimeInput extends StatefulWidget {
  final String labelText;
  final String? hintText;
  final DateTime? initialDatetime; // 接受完整的初始日期和时间
  final Function(DateTime?) onDatetimeSelected; // 回调函数

  const FakeDatetimeInput({
    super.key,
    required this.labelText,
    this.hintText,
    this.initialDatetime,
    required this.onDatetimeSelected,
  });

  @override
  State<FakeDatetimeInput> createState() => _FakeDatetimeInputState();
}

class _FakeDatetimeInputState extends State<FakeDatetimeInput> {
  DateTime? _selectedDatetime;

  // 确保清除按钮和选择器能够协同工作
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _selectedDatetime = widget.initialDatetime;
  }

  // 格式化日期和时间显示
  String get _formattedDatetime {
    if (_selectedDatetime == null) {
      return widget.hintText ?? 'selectDateAndTime'.tr;
    }
    final dt = _selectedDatetime!;
    final date =
        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }

  // 核心方法：链式调用日期选择器和时间选择器
  Future<void> _selectDatetime(BuildContext context) async {
    if (_isProcessing) return; // 防止重复点击
    _isProcessing = true;

    // 1. 日期选择器：使用当前日期或已选日期作为初始值
    final initialDate = _selectedDatetime ?? DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );

    if (pickedDate == null) {
      _isProcessing = false;
      return; // 用户取消选择日期
    }

    // 2. 时间选择器：使用已选时间的 TimeOfDay 作为初始值
    final initialTime = TimeOfDay.fromDateTime(initialDate);

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    _isProcessing = false; // 处理完毕，可以再次点击

    if (pickedTime == null) {
      return; // 用户取消选择时间
    }

    // 3. 组合：将选中的日期和时间组合成一个新的 DateTime
    final finalDatetime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      _selectedDatetime = finalDatetime; // 更新内部状态
    });

    widget.onDatetimeSelected(finalDatetime); // 通知外部
  }

  // 清除日期的逻辑
  void _clearDatetime() {
    setState(() {
      _selectedDatetime = null; // 清除内部状态
    });
    widget.onDatetimeSelected(null); // 通知外部日期已清除
  }

  // 构建动态的后缀图标 Widget (包括清除按钮)
  Widget _buildSuffixIcon() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_selectedDatetime != null)
          IconButton(
            icon: const Icon(Icons.clear, size: 20),
            onPressed: _clearDatetime,
          ),

        // 日历/时钟图标，用于打开选择器
        IconButton(
          icon: const Icon(Icons.date_range, size: 20),
          onPressed: () => _selectDatetime(context),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasDatetime = _selectedDatetime != null;

    return GestureDetector(
      onTap: () => _selectDatetime(context),

      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          suffixIcon: _buildSuffixIcon(),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
        ),

        child: Text(
          _formattedDatetime,
          style: TextStyle(
            color: hasDatetime
                ? Theme.of(context).textTheme.titleMedium?.color
                : MyColor.text(0.6),
          ),
        ),
      ),
    );
  }
}
