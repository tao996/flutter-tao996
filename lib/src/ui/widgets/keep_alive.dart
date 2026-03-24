import 'package:flutter/material.dart';

class KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const KeepAliveWrapper({super.key, required this.child});

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用
    return widget.child;
  }
}
/*
@override
Widget build(BuildContext context) {
  final c = controller; // Get.find 或 GetView 自动提供的 controller
  
  return MyScaffold(
    body: PageView(
      controller: c.pageController,
      onPageChanged: (index) => c.selectedIndex.value = index,
      children: [
        // 使用包装器，这样即使首页有长列表，滑回来位置也不会变
        KeepAliveWrapper(child: _buildHomeContent()), 
        KeepAliveWrapper(child: _buildMessageContent()),
        const Center(child: Text('个人中心')), // 如果这页不需要状态保持，就不包
      ],
    ),
    bottomNavigationBar: Obx(() => BottomNavigationBar(
      currentIndex: c.selectedIndex.value,
      onTap: (index) {
        c.pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: '消息'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
      ],
    )),
  );
}
*/