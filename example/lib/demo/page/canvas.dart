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
  PsLayer? testLayer;
  PsLayer? textLayer;

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  Future<void> _prepareData() async {
    await _testLayer();
    await _prepareTextData();
    setState(() => isReady = true);
  }

  Future<void> _testLayer() async {
    // 1. 预渲染一个文字节点 (转为 ui.Image)
    final textImage = await tu.draw.renderText(
      "Gemini",
      size: const Size(200, 100),
      color: Colors.white,
      fontSize: 40,
      fontWeight: FontWeight.bold,
    );

    // 2. 构建图层模型
    testLayer = PsLayer(
      // 定义蒙板：整个图层的可见区域是一个圆角矩形
      mask: PsMask(rect: const Rect.fromLTWH(50, 50, 300, 300), radius: 40.0),
      nodes: [
        // 背景：基础矢量矩形
        PsNode(
          type: PsNodeType.rect,
          size: const Size(300, 300),
          position: const Offset(50, 50),
          radius: 0,
          data: null,
          style: {'color': Colors.blueGrey},
        ),
        // 圆形：基础矢量圆形
        PsNode(
          type: PsNodeType.circle,
          size: const Size(100, 100),
          position: const Offset(80, 80),
          radius: 0,
          data: null,
          style: {'color': Colors.amber},
        ),

        // 文字：已经通过 DrawUtil 转换后的图像节点
        PsNode(
          type: PsNodeType.text,
          size: const Size(200, 100),
          position: const Offset(100, 150),
          radius: 0,
          data: textImage,
          style: {'opacity': 0.9},
        ),
      ],
    );
  }

  void updateLayer() async {
    // 1. 如果需要生成新的 ui.Image 资源
    final newTextImage = await tu.draw.renderText(
      "Updated!",
      size: const Size(200, 100),
      color: Colors.red,
    );

    // 2. 释放旧资源 (非常重要，防止内存泄漏)
    for (var node in testLayer!.nodes) {
      if (node.data is ui.Image) {
        (node.data as ui.Image).dispose();
      }
    }

    // 3. 构建新的 Layer 并通知 UI
    setState(() {
      testLayer = PsLayer(
        mask: PsMask(rect: const Rect.fromLTWH(0, 0, 400, 400), radius: 20),
        nodes: [
          PsNode(
            type: PsNodeType.text,
            size: const Size(200, 100),
            position: const Offset(50, 50), // 修改了位置
            radius: 0,
            data: newTextImage,
          ),
        ],
      );
    });
  }

  void toggleMaskBorder() {
    setState(() {
      final oldMask = testLayer!.mask!;
      testLayer = PsLayer(
        nodes: testLayer!.nodes,
        mask: PsMask(
          rect: oldMask.rect,
          radius: oldMask.radius,
          showBorder: !oldMask.showBorder, // 切换显示
        ),
      );
    });
  }

  void _refresh() async {
    updateLayer();
  }

  Future<void> _prepareTextData() async {
    final List<PsNode> nodes = [];

    // 定义统一的字号
    const double testFontSize = 40;

    nodes.add(
      await tu.ps.textNode(
        "a",
        position: const Offset(300, 10),
        size: const Size(40, 40),
        fontSize: testFontSize,
        color: Colors.orange,
        backgroundColor: Colors.lime,
      ),
    );
    nodes.add(
      await tu.ps.textNode(
        "a",
        position: const Offset(300, 70),
        size: const Size(30, 30),
        fontSize: testFontSize,
        color: Colors.orange,
        backgroundColor: Colors.lime,
      ),
    );

    // 自动计算尺寸 (贴边)
    nodes.add(
      await tu.ps.textNode(
        "a",
        position: const Offset(350, 10),
        size: null, // 传入 null 触发自动计算
        fontSize: 40,
        backgroundColor: Colors.lime,
      ),
    );

    // 1. 标准大小 (1:1)
    nodes.add(
      await tu.ps.textNode(
        "Standard 40",
        position: const Offset(50, 60),
        size: const Size(200, 50),
        fontSize: testFontSize,
        color: Colors.blue,
        backgroundColor: Colors.grey,
      ),
    );

    // 2. 容器缩小 (由于 fontSize 还是 40，渲染出来的 ui.Image 很大，但在画布上会被缩小，看起来会更锐利)
    nodes.add(
      await tu.ps.textNode(
        "Shrink 40",
        position: const Offset(50, 130),
        size: const Size(100, 25), // 容器减半
        fontSize: testFontSize,
        color: Colors.green,
        backgroundColor: Colors.grey,
      ),
    );

    // 3. 容器放大 (由于 fontSize 还是 40，渲染出来的图片分辨率有限，拉伸到 400 宽可能会出现模糊)
    nodes.add(
      await tu.ps.textNode(
        "Stretch 40",
        position: const Offset(50, 180),
        size: const Size(400, 100), // 容器翻倍
        fontSize: testFontSize,
        color: Colors.red,
        backgroundColor: Colors.grey,
      ),
    );

    textLayer = PsLayer(
      mask: PsMask(rect: const Rect.fromLTWH(0, 0, 500, 400), showBorder: true),
      nodes: nodes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(
        title: const Text("Canvas Test1"),
        actions: [
          MyButton('蒙板边框', onPressed: toggleMaskBorder),
          MyButton('刷新重绘', onPressed: _refresh),
        ].withRowWidth(),
      ),
      singleChildScrollView: true,
      body: Column(
        children: [
          !isReady
              ? const Center(child: CircularProgressIndicator())
              : MyLayout.miniColumn([
                  Text('基本使用'),
                  MyLayout.height,
                  Center(
                    child: Container(
                      width: 400,
                      height: 400,
                      color: Colors.grey[200],
                      child: testLayer!.draw(),
                    ),
                  ),

                  Text('文字比较'),
                  MyLayout.height,
                  Center(
                    child: Container(
                      width: 400,
                      height: 400,
                      color: Colors.grey[200],
                      child: textLayer!.draw(),
                    ),
                  ),
                ]),
          MyLayout.height24,
        ],
      ),
    );
  }
}
