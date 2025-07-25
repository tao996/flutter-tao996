import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../tao996.dart';


class MySearchInput extends StatelessWidget {
  final String? hintText;
  late final MySearchController c;

  MySearchInput(MySearchMethods methods, {super.key, this.hintText}) {
    c = Get.put(MySearchController(methods: methods));
  }

  @override
  Widget build(BuildContext context) {
    // return Container(
    //   height: 40.0, // 设置合适的高度
    //   decoration: BoxDecoration(
    //     color: Colors.grey[200], // 设置浅色背景
    //     borderRadius: BorderRadius.circular(8.0), // 可选：添加圆角
    //   ),
    //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
    //   child: Row(
    //     children: [
    //       const Icon(Icons.search, color: Colors.grey),
    //       const SizedBox(width: 8.0),
    //       Expanded(
    //         child: TextField(
    //           onChanged: (value) {
    //           },
    //           style: const TextStyle(fontSize: 16.0),
    //           decoration: const InputDecoration(
    //             hintText: '搜索',
    //             border: InputBorder.none, // 移除边框
    //             hintStyle: TextStyle(color: Colors.grey),
    //             isDense: true, // 减小 TextField 的内部 padding
    //             contentPadding: EdgeInsets.zero, // 移除内部 padding
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );

    return Container(
      height: 36.0, // 设置合适的高度
      decoration: BoxDecoration(
        color: Colors.grey[200], // 设置浅色背景
        borderRadius: BorderRadius.circular(4.0), // 可选：添加圆角
      ),
      padding: const EdgeInsets.fromLTRB(8, 2, 0, 2),
      child: Obx(
        () => TextField(
          controller: c.textController,
          onChanged: c.bindChanged,
          onSubmitted: c.bindSubmitted,
          style: const TextStyle(fontSize: 16.0),
          textAlignVertical: TextAlignVertical.center,
          // 设置垂直居中
          decoration: InputDecoration(
            border: InputBorder.none,
            // 移除未获取焦点时的边框
            focusedBorder: InputBorder.none,
            // 移除获取焦点时的边框
            // 移除边框
            hintStyle:const TextStyle(color: Colors.grey),
            isDense: true,
            // 减小 TextField 的内部 padding
            contentPadding: EdgeInsets.zero,
            // 移除内部 padding
            hintText: hintText ?? 'Search'.tr,
            // prefixIcon: const Icon(Icons.search),
            suffixIcon:
                c.showClearIcon.value
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: c.bindClearInput,
                    )
                    : null,
          ),
        ),
      ),
    );
  }
}
