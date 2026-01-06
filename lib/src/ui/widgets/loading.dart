import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyLoading extends StatelessWidget {
  const MyLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
/// 放在 AppBar bottom 中
PreferredSizeWidget? myAppBarLoading(RxBool isLoading) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(2.0),
    child: Obx(
      () => isLoading.value
          ? const ColorfulProgressLoader()
          : const SizedBox(height: 2.0), // 隐藏时占位，防止 AppBar 高度跳动
    ),
  );
}

class ColorfulProgressLoader extends StatelessWidget
    implements PreferredSizeWidget {
  const ColorfulProgressLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4.0,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.purple, Colors.red, Colors.orange],
        ),
      ),
      child: const LinearProgressIndicator(
        backgroundColor: Colors.transparent,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(4.0);
}
