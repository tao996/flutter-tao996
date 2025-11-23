import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/src/const/color.dart';
import 'package:tao996/src/utils/fn_util.dart';

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
      return widget.hintText ?? 'selectADate'.tr;
    }
    final year = _selectedDate!.year;
    final month = _selectedDate!.month.toString().padLeft(2, '0');
    final day = _selectedDate!.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  // 核心方法：显示日期选择器
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
                : MyColor.text(0.6),
          ),
        ),
      ),
    );
  }
}

class FakeTimeInput extends StatefulWidget {
  // 初始时间，从中提取 TimeOfDay
  final DateTime? initTime;

  // 输入框的标签文本
  final String labelText;

  // 选择时间后的回调函数，返回一个包含日期和时间的新 DateTime 对象
  final Function(DateTime?) onTimeSelected;

  // 提示文本
  final String? hintText;

  const FakeTimeInput({
    super.key,
    this.initTime,
    required this.labelText,
    required this.onTimeSelected,
    this.hintText,
  });

  @override
  State<FakeTimeInput> createState() => _FakeTimeInputState();
}

class _FakeTimeInputState extends State<FakeTimeInput> {
  // 内部保存的完整 DateTime 对象（包含日期信息）
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.initTime;
  }

  // 格式化日期显示（使用 padLeft 确保两位数）
  String get _formattedTime {
    if (_selectedDateTime == null) {
      return widget.hintText ?? 'selectATime'.tr;
    }
    final timeOfDay = TimeOfDay.fromDateTime(_selectedDateTime!);
    final hour = timeOfDay.hour.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _openTimeDialog(BuildContext context) async {
    // 确定 initialTime：如果已选，则使用已选时间；否则使用当前时间
    final initialTime = _selectedDateTime != null
        ? TimeOfDay.fromDateTime(_selectedDateTime!)
        : TimeOfDay.now();

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(data: ThemeData(useMaterial3: true), child: child!);
      },
    );

    if (picked != null) {
      // 1. 创建一个新的 DateTime 对象来保存结果。
      //    保持日期部分（年、月、日）不变，只更新时间部分（时、分）。
      DateTime newDateTime;
      if (_selectedDateTime != null) {
        // 如果有初始日期，则保持其日期部分
        newDateTime = DateTime(
          _selectedDateTime!.year,
          _selectedDateTime!.month,
          _selectedDateTime!.day,
          picked.hour,
          picked.minute,
        );
      } else {
        // 如果没有初始日期，则使用当前日期作为日期部分
        final now = DateTime.now();
        newDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          picked.hour,
          picked.minute,
        );
      }

      // 2. 更新状态和文本显示
      setState(() {
        _selectedDateTime = newDateTime;
      });

      // 3. 调用回调函数
      widget.onTimeSelected(_selectedDateTime);
    }
  }

  // 新增：清除日期的逻辑
  void _clearTime() {
    setState(() {
      _selectedDateTime = null;
    });
    widget.onTimeSelected(null);
  }

  // 构建动态的后缀图标 Widget
  Widget _buildSuffixIcon() {
    return Row(
      // 确保 Row 只占用其子 Widget 所需的最小空间
      mainAxisSize: MainAxisSize.min,
      children: [
        // 只有当日期不为空时才显示清除按钮
        if (_selectedDateTime != null)
          IconButton(
            icon: const Icon(Icons.clear, size: 20),
            onPressed: _clearTime,
          ),

        // 日历图标，始终显示
        IconButton(
          icon: const Icon(Icons.access_time, size: 20),
          onPressed: () => _openTimeDialog(context), // 点击日历图标也打开选择器
        ),
        const SizedBox(width: 4), // 留出一点边距
      ],
    );
  }

  // ----------------------------------------------------
  // 构建 UI
  // ----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final bool hasDate = _selectedDateTime != null;
    // GestureDetector 捕获点击事件
    return GestureDetector(
      // 点击整个区域都可以打开日期选择器
      onTap: () => _openTimeDialog(context),

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
          _formattedTime,
          style: TextStyle(
            // 如果没有日期，使用 HintText 的颜色
            color: hasDate
                ? Theme.of(context).textTheme.titleMedium?.color
                : MyColor.text(0.6),
          ),
        ),
      ),
    );
  }
}
