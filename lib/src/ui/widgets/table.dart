import 'package:flutter/material.dart';

class MyTable extends StatelessWidget {
  final List<DataColumn> headers;

  /// 数据，如果需要索引 `List.generate(data.length, (index) {})` 否则可以使用 `data.map`
  final List<DataRow> rows;
  final double dataRowHeight;
  final double? dataRowMaxHeight;
  final double? dataRowMinHeight;

  /// 表头 [headers]
  /// [rows] 数据源
  const MyTable({
    required this.headers,
    required this.rows,
    this.dataRowHeight = 60,
    this.dataRowMaxHeight,
    this.dataRowMinHeight,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Card(
              // 设置圆角半径
              shape: RoundedRectangleBorder(
                // borderRadius: BorderRadius.circular(0),
              ),
              // 可选：设置阴影
              elevation: 1,
              child: DataTable(
                dataRowMaxHeight: dataRowMaxHeight ?? dataRowHeight,
                dataRowMinHeight: dataRowMinHeight ?? dataRowHeight,
                columnSpacing: 24,
                dividerThickness: 1,
                headingRowColor: WidgetStateProperty.all(
                  Colors.transparent,
                ),
                dataRowColor: WidgetStateProperty.all(
                  Colors.transparent,
                ),
                headingTextStyle: TextStyle(fontWeight: FontWeight.bold),
                columns: headers,
                rows: rows,
              ),
            ),
          ),
        );
      },
    );
  }
}