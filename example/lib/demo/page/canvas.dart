import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:tao996/tao996.dart';

class CanvasTestPage extends StatefulWidget {
  const CanvasTestPage({super.key});

  @override
  State<CanvasTestPage> createState() => _CanvasTestPageState();
}

class _CanvasTestPageState extends State<CanvasTestPage> {
  bool isReady = false;

  late MyPs ps;
  late MyPs ps2;

  @override
  void initState() {
    super.initState();
    // 初始化管理器
    ps = MyPs(
      style: PsStyle(size: Size(300, 300), backgroundColor: Colors.grey),
    );
    ps2 = MyPs(
      style: PsStyle(size: Size(300, 300), backgroundColor: Colors.grey),
    );

    _prepareData();
  }

  @override
  void dispose() {
    // 统一销毁 GPU 资源，防止内存泄漏
    ps.onDestroy();
    ps2.onDestroy();
    super.dispose();
  }

  Future<void> _prepareData() async {
    await _preparePsScene();
    await _preparePs2Scene();
    if (mounted) setState(() => isReady = true);
  }

  /// 基础场景：展示 Rect, Circle 和 Gemini 文字
  Future<void> _preparePsScene() async {
    // 1. 背景
    ps.addRectNode(inlineStyle: PsStyle(color: Colors.grey));

    // 3. 居中偏下 100 像素的 SVG
    await ps.addSvgNode(
      '''
<svg width="100" height="100" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <circle cx="50" cy="50" r="40" stroke="black" stroke-width="3" fill="red" />
</svg>
''',
      size: Size(200, 200),
      inlineStyle: PsStyle(
        position: Offset(0, 150), // 垂直向下偏移 150
      ),
    );

    ps.addRectNode(
      inlineStyle: PsStyle(
        size: Size(50, 50),
        center: true, // 居中
        backgroundColor: Colors.blue,
        radius: 15, // 圆角
        borderWidth: 1, // 边框宽度
        borderColor: Colors.red, // 边框颜色
        shadow: BoxShadow(
          // 阴影
          color: Colors.green,
          blurRadius: 1,
          offset: Offset(1, 1),
        ),
      ),
    );
    ps.addRectNode(
      inlineStyle: PsStyle(
        size: Size(150, 150),
        center: true,
        radius: 20,
        borderWidth: 2,
        borderColor: Colors.blue,
        // backgroundColor 为 null
        shadow: BoxShadow(
          color: Colors.blue.withOpacity(0.5),
          blurRadius: 20,
          offset: Offset(0, 10),
        ),
      ),
    );
    // 1. 创建一个只有红边的空心圆
    ps.addCircleNode(
      inlineStyle: PsStyle(
        size: Size(100, 100),
        center: true,
        borderWidth: 2,
        borderColor: Colors.red,
        // backgroundColor 保持为 null，自动透明
      ),
    );

    // 2. 创建一个带阴影但透明的矩形框
    ps.addRectNode(
      inlineStyle: PsStyle(
        size: Size(300, 200),
        center: true,
        radius: 12,
        borderWidth: 1,
        borderColor: Colors.blue,
        shadow: BoxShadow(color: Colors.black),
      ),
    );

    ps.addLine(
      from: Offset(0, 0),
      to: Offset(300, 300), // 300x300 画布的对角线
      inlineStyle: PsStyle(borderColor: Colors.red, borderWidth: 5),
    );

    // 2. 绝对居中的文字 (不需要计算 Offset，设置 center: true 即可)
    await ps.addTextNode(
      "HELLO WORLD",
      tag: 'label',
      inlineStyle: PsStyle(fontSize: 20, color: Colors.white),
    );
  }

  /// 文字比较场景：展示自动贴边与缩放效果
  Future<void> _preparePs2Scene() async {
    // 1. 画一个从左到右的渐变背景矩形
    ps2.addRectNode(
      inlineStyle: PsStyle(
        size: Size(200, 100),
        center: true,
        radius: 15,
        backgroundGradient: LinearGradient(
          colors: [Colors.purple, Colors.orange],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        shadow: BoxShadow(
          color: Colors.black45,
          blurRadius: 10,
          offset: Offset(5, 5),
        ),
      ),
    );

    // 2. 一个文字带渐变色
    await ps2.addTextNode(
      "Gradient Text",
      tag: 'grad_text',
      inlineStyle: PsStyle(
        position: Offset(0, -80),
        center: true,
        fontSize: 30,
        foregroundGradient: RadialGradient(
          colors: [Colors.yellow, Colors.red],
          stops: [0.0, 1.0],
        ),
      ),
    );

    await ps2.addTextNode(
      "SHADOW TEXT",
      inlineStyle: PsStyle(
        center: true,
        fontSize: 40,
        // 1. 设置渐变前景
        foregroundGradient: LinearGradient(
          colors: [Colors.cyan, Colors.blueAccent],
        ),
        // 2. 设置文字阴影
        textShadow: BoxShadow(
          color: Colors.black.withOpacity(0.5),
          offset: Offset(4, 4),
          blurRadius: 6,
        ),
      ),
    );

    // 3. 一条渐变色的线条
    ps2.addLine(
      from: Offset(50, 200),
      to: Offset(250, 100),
      inlineStyle: PsStyle(
        borderWidth: 8,
        foregroundGradient: LinearGradient(
          colors: [Colors.green, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  void toggleMaskBorder() {
    if (ps.mask != null) {
      setState(() {
        final oldMask = ps.mask!;
        ps.mask = PsMask(
          rect: oldMask.rect,
          radius: oldMask.radius,
          showBorder: !oldMask.showBorder,
        );
      });
    }
  }

  void _refresh() async {
    // 释放并清空现有资源
    ps.onDestroy();
    setState(() => isReady = false);
    await _prepareData();
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(
        title: const Text("MyPs Canvas Engine"),
        actions: [
          MyButton(
            'scale',
            onPressed: () {
              final factory = tu.number.getRandomElement<double>([
                0.5,
                1,
                1.5,
                2,
              ]);
              dprint('随机因子：$factory');
              ps.scale(factory, tag: 'label');
            },
          ),
          MyButton(
            'rotate',
            onPressed: () {
              final factory = tu.number.getRandomElement<double>([
                0,
                45,
                90,
                135,
                180,
                225,
                270,
                315,
                360,
              ]);
              dprint('随机因子：$factory');
              ps.rotate(factory, tag: 'label');
            },
          ),
          MyButton('蒙板边框', onPressed: toggleMaskBorder),
          MyButton('刷新重绘', onPressed: _refresh),
        ].withRowWidth(),
      ),
      singleChildScrollView: true,
      body: Column(
        children: [
          !isReady
              ? const SizedBox(
                  height: 400,
                  child: Center(child: CircularProgressIndicator()),
                )
              : MyLayout.miniColumn([
                  const Text('基本使用 (Rect, Circle, Text)'),
                  MyLayout.height,
                  Center(child: ps.build()),

                  const Text('渐变功能'),
                  MyLayout.height,
                  Center(child: ps2.build()),
                ]),
          MyLayout.height24,
        ],
      ),
    );
  }
}
