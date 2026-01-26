/*
* RenderNode (渲染节点): 存储图形数据（位置、大小、资源引用）。
* Mask (蒙板定义): 仅作为一个 Path 或 Alpha 区域。
* Composite (合成器): 遍历节点，按顺序在 saveLayer 的上下文中绘制。
*/
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:tao996/tao996.dart';

class MyPs extends ChangeNotifier {
  final PsStyle style;
  final List<PsClass> classes = [];
  final List<PsNode> nodes = [];
  final List<ui.Image> _resources = [];
  late final Size canvasSize;
  PsMask? mask;

  MyPs({this.mask, required this.style}) {
    canvasSize = style.drawSize;
  }

  /// 内部工具：合并样式并注入 canvasSize
  PsStyle _prepareStyle(List<String>? names, PsStyle? inline) {
    PsStyle style = _mergeStyles(names, inline);
    style.canvasSize = canvasSize; // 强制注入当前画布尺寸
    style.margin =
        (this.style.padding ?? EdgeInsets.zero) +
        (inline?.margin ?? EdgeInsets.zero);
    return style;
  }

  Future<MyPs> addTextNode(
    String text, {
    String? tag,
    List<String>? classNames,
    PsStyle? inlineStyle,
  }) async {
    PsStyle finalStyle = _prepareStyle(classNames, inlineStyle);

    if (finalStyle.size == null) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(fontSize: finalStyle.fontSize ?? 20),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      finalStyle.size = tp.size;
    }
    finalStyle.inherit = false; // [重要] 确保文字使用 tp.size 而不是继承画布
    final img = await tu.draw.renderText(
      text,
      size: finalStyle.size!,
      fontSize: finalStyle.fontSize,
      color: finalStyle.color ?? Colors.black,
    );

    _resources.add(img);
    nodes.add(
      PsNode(type: PsNodeType.text, data: img, style: finalStyle, tag: tag),
    );
    return this;
  }

  /// 添加矩形节点
  MyPs addRectNode({
    String? tag,
    List<String>? classNames,
    PsStyle? inlineStyle,
  }) {
    nodes.add(
      PsNode(
        type: PsNodeType.rect,
        data: null,
        style: _prepareStyle(classNames, inlineStyle),
        tag: tag,
      ),
    );
    return this;
  }

  /// 添加圆形节点
  MyPs addCircleNode({
    String? tag,
    List<String>? classNames,
    PsStyle? inlineStyle,
  }) {
    nodes.add(
      PsNode(
        type: PsNodeType.circle,
        data: null,
        style: _prepareStyle(classNames, inlineStyle),
        tag: tag,
      ),
    );
    return this;
  }

  /// 3. 添加图片节点 (位图)
  Future<MyPs> addImageNode(
    ui.Image image, {
    String? tag,
    List<String>? classNames,
    PsStyle? inlineStyle,
  }) async {
    PsStyle finalStyle = _mergeStyles(classNames, inlineStyle);
    finalStyle.size ??= Size(image.width.toDouble(), image.height.toDouble());
    _resources.add(image);

    nodes.add(
      PsNode(
        type: PsNodeType.image,
        data: null,
        style: _prepareStyle(classNames, inlineStyle),
        tag: tag,
      ),
    );
    return this;
  }

  /// 4. 添加 SVG 节点 (转换为位图以提高混合渲染性能)
  /// 添加 SVG 节点 (带缩放修正)
  Future<MyPs> addSvgNode(
    String svgString, {
    required Size size,
    String? tag,
    List<String>? classNames,
    PsStyle? inlineStyle,
  }) async {
    PsStyle finalStyle = _mergeStyles(classNames, inlineStyle);
    finalStyle.size ??= size;
    final img = await tu.draw.renderSvg(svgString, size: finalStyle.size!);
    _resources.add(img);
    nodes.add(
      PsNode(
        type: PsNodeType.svg,
        data: null,
        style: _prepareStyle(classNames, inlineStyle),
        tag: tag,
      ),
    );
    return this;
  }

  /// 添加线条节点
  MyPs addLine({
    Offset? from,
    Offset? to,
    String? tag,
    List<String>? classNames,
    PsStyle? inlineStyle,
  }) {
    PsStyle finalStyle = _prepareStyle(classNames, inlineStyle);
    double halfWidth = (finalStyle.borderWidth ?? 1.0) / 2;

    if (from != null && to != null) {
      // 自动计算缩进：让线条的边缘刚好贴在画布边缘，而不是中心点贴边
      // 这里我们简单处理，直接微调 position 和 size
      finalStyle.position = Offset(from.dx + halfWidth, from.dy + halfWidth);
      finalStyle.size = Size(
        (to.dx - from.dx) - (halfWidth * 2),
        (to.dy - from.dy) - (halfWidth * 2),
      );
      finalStyle.center = false;
    } else if (finalStyle.inherit) {
      // 如果是继承画布，也要缩进
      finalStyle.position = Offset(halfWidth, halfWidth);
      finalStyle.size = Size(
        canvasSize.width - (halfWidth * 2),
        canvasSize.height - (halfWidth * 2),
      );
    }

    nodes.add(
      PsNode(type: PsNodeType.line, data: null, style: finalStyle, tag: tag),
    );
    return this;
  }

  /// 样式合并逻辑
  PsStyle _mergeStyles(List<String>? names, PsStyle? inline) {
    PsStyle base = PsStyle();
    if (names != null) {
      for (var name in names) {
        final matched = classes.firstWhere(
          (c) => c.name == name,
          orElse: () => PsClass(name: '', style: PsStyle()),
        );
        base = base.copyWith(matched.style);
      }
    }
    return base.copyWith(inline);
  }

  /// 资源释放：务必在 Widget 的 dispose 中调用
  void onDestroy() {
    for (var img in _resources) {
      img.dispose();
    }
    _resources.clear();
    nodes.clear();
  }

  // 1. 在 MyPs 中增加一个临时变量记录上一次的手指位置
  Offset? _lastPanOffset;

  /// 构建最终渲染组件
  ///
  /// ```dart
  /// // 如何在 Rx 中应用，在 Controller 中
  /// var scaleFactor = 1.0.obs;
  /// // 在 UI 中
  /// myPs.build(),
  /// // 监听 Rx 变化并同步给 MyPs
  /// once(scaleFactor, (val) {
  ///   myPs.scale(val, tag: 'logo');
  /// });
  /// ```
  Widget build({bool enableHitTest = false}) {
    final child = ListenableBuilder(
      listenable: this, // 监听 myPs 的变化
      builder: (context, child) {
        // 每当 notifyListeners 被调用，这里都会重新执行
        return SizedBox(
          width: canvasSize.width,
          height: canvasSize.height,
          child: CustomPaint(
            painter: MyPainter(this, enableHitTest: enableHitTest),
            size: Size.infinite,
          ),
        );
      },
    );
    if (!enableHitTest) {
      return child;
    }

    return LayoutBuilder(
      // 使用 LayoutBuilder 方便获取实时约束
      builder: (context, constraints) {
        // 这里的 constraints.biggest 就是显示的 Size
        final double sX = constraints.biggest.width / canvasSize.width;
        final double sY = constraints.biggest.height / canvasSize.height;

        return GestureDetector(
          onTapDown: (details) {
            dprint('onTapDown');
            final node = findNodeAt(details.localPosition);

            // 核心逻辑优化：
            if (node == null) {
              // 1. 点击空白处，取消当前所有选中
              toggleSelection(null);
            } else {
              // 2. 如果点击的节点不是当前选中的节点，才去切换它
              // 这样如果点中的是已选中的节点，就不会触发 toggle 里的“取消选中”逻辑
              if (selectedTag != node.tag) {
                toggleSelection(node.tag);
              }
            }
          },
          onPanStart: (details) {
            _lastPanOffset = details.localPosition; // 记录起点
            if (selectedTag != null) {
              bringToFront(selectedTag!);
            }
          },
          onPanEnd: (_) {
            _lastPanOffset = null; // 清空记录
          },
          onPanUpdate: (details) {
            if (selectedTag != null && _lastPanOffset != null) {
              // 计算手指在画布上的实际位移 (当前点 - 上一个点)
              final Offset screenDelta =
                  details.localPosition - _lastPanOffset!;
              _lastPanOffset = details.localPosition; // 更新记录点

              // 关键修正：计算画布的物理缩放比
              // 我们直接用 renderBox 拿到 CustomPaint 渲染在屏幕上的真实大小
              final RenderBox renderBox =
                  context.findRenderObject() as RenderBox;
              final double sx = renderBox.size.width / canvasSize.width;
              final double sy = renderBox.size.height / canvasSize.height;

              // 转换为逻辑坐标位移
              final logicalDelta = Offset(
                screenDelta.dx / sx,
                screenDelta.dy / sy,
              );

              updateNodePosition(selectedTag!, logicalDelta);
            }
          },
          child: child,
        );
      },
    );
  }

  /// 缩放功能
  void scale(double factor, {String? tag}) {
    bool changed = false;
    if (tag == null) {
      for (var node in nodes) {
        node.style.scale = factor;
        changed = true;
      }
    } else {
      for (var node in nodes) {
        if (node.tag == tag) {
          node.style.scale = factor;
          changed = true;
        }
      }
    }

    // 2. 关键：通知 UI 刷新
    if (changed) notifyListeners();
  }

  // move 方法也需要加上
  void move(String tag, Offset offset) {
    for (var node in nodes) {
      if (node.tag == tag) {
        node.style.position = (node.style.position) + offset;
        notifyListeners(); // 刷新
      }
    }
  }

  /// 旋转功能：angle 为角度（0-360）
  void rotate(double angle, {String? tag}) {
    final double radians = angle * (math.pi / 180); // 角度转弧度
    bool changed = false;

    if (tag == null) {
      for (var node in nodes) {
        node.style.rotate = radians;
        changed = true;
      }
    } else {
      for (var node in nodes) {
        if (node.tag == tag) {
          node.style.rotate = radians;
          changed = true;
        }
      }
    }

    if (changed) notifyListeners();
  }

  /// 导出画布为图片
  /// [size] 导出的目标尺寸，如果不指定则使用 canvasSize
  ///
  /// ```dart
  /// // 1. 导出为 4K 高清图
  /// ui.Image highResImage = await myPs.exportImage(size: Size(3840, 2160));

  /// // 2. 将 ui.Image 转换为字节流以保存或分享
  /// ByteData? byteData = await highResImage.toByteData(format: ui.ImageByteFormat.png);
  /// Uint8List pngBytes = byteData!.buffer.asUint8List();
  /// ```
  Future<ui.Image> exportImage({Size? size}) async {
    final exportSize = size ?? canvasSize;

    // 1. 创建记录器和画布
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Offset.zero & exportSize);

    // 2. 创建 Painter 实例
    // 我们直接复用现有的 MyPainter 逻辑
    final painter = MyPainter(this);

    // 3. 执行绘制
    // 注意：painter.paint 内部已经处理了从 canvasSize 到 exportSize 的缩放
    painter.paint(canvas, exportSize);

    // 4. 结束录制并生成图片
    final picture = recorder.endRecording();
    return await picture.toImage(
      exportSize.width.toInt(),
      exportSize.height.toInt(),
    );
  }

  /// 快速置顶：获取当前最大值并 +1
  void bringToFront(String tag) {
    final index = nodes.indexWhere((n) => n.tag == tag);
    if (index < 0) {
      print('Node with tag $tag not found');
      return;
    }
    final node = nodes[index];
    int maxZ = nodes.fold(
      0,
      (max, n) => n.style.zIndex > max ? n.style.zIndex : max,
    );

    node.style.zIndex = maxZ + 1;
    notifyListeners();
  }

  /// 快速置底：获取当前最小值并 -1
  void sendToBack(String tag) {
    final index = nodes.indexWhere((n) => n.tag == tag);
    if (index < 0) {
      print('Node with tag $tag not found');
      return;
    }
    final node = nodes[index];
    int minZ = nodes.fold(
      0,
      (min, n) => n.style.zIndex < min ? n.style.zIndex : min,
    );
    node.style.zIndex = minZ - 1;
    notifyListeners();
  }

  /// 向上移动一层
  void moveUp(String tag) {
    int index = nodes.indexWhere((n) => n.tag == tag);
    if (index != -1 && index < nodes.length - 1) {
      final node = nodes.removeAt(index);
      nodes.insert(index + 1, node);
      notifyListeners();
    }
  }

  /// 向下移动一层
  void moveDown(String tag) {
    int index = nodes.indexWhere((n) => n.tag == tag);
    if (index != -1 && index > 0) {
      final node = nodes.removeAt(index);
      nodes.insert(index - 1, node);
      notifyListeners();
    }
  }

  // 清空画布的方法，方便重新创作
  void clear() {
    nodes.clear();
    notifyListeners();
  }

  PsNode? findNodeAt(Offset localOffset) {
    // 1. 必须从后往前找，因为最后加入（zIndex更高）的在上面
    final sortedNodes = List<PsNode>.from(nodes);
    sortedNodes.sort((a, b) {
      int cmp = (b.style.zIndex).compareTo(a.style.zIndex);
      if (cmp != 0) return cmp;
      return nodes.indexOf(b).compareTo(nodes.indexOf(a));
    });

    for (var node in sortedNodes) {
      // 2. 获取你那个强大的公式算出来的 rect

      Rect rect = node.rect;
      // print("TextRect:${node.tag} => $rect, Click: $localOffset");
      // 3. 【关键修正】如果是文字，手动扩大它的判定矩形
      // inflate(15) 会让感应区域向四周各延伸 15 像素
      if (node.type == PsNodeType.text) {
        rect = rect.inflate(15.0);
      }

      // 4. 处理旋转点击（如果你的文字旋转了）
      if (node.style.rotate != 0) {
        final path = Path()..addRect(rect);
        final center = node.rect.center;
        final matrix = Matrix4.identity()
          ..translate(center.dx, center.dy)
          ..rotateZ(node.style.rotate)
          ..translate(-center.dx, -center.dy);

        if (path.transform(matrix.storage).contains(localOffset)) {
          return node;
        }
      } else {
        // 5. 普通矩形判定
        if (rect.contains(localOffset)) {
          return node;
        }
      }
    }
    return null;
  }

  String? selectedTag; // 当前选中的节点标签
  double _dashOffset = 0.0; // 蚂蚁线的偏移量
  double get dashOffset => _dashOffset;
  // 切换选中状态
  void toggleSelection(String? tag) {
    if (tag == null || selectedTag == tag) {
      selectedTag = null; // 再次点击取消选中
    } else {
      selectedTag = tag;
    }
    dprint('选中了节点 $selectedTag');
    notifyListeners();
  }

  // 驱动蚂蚁线滚动的更新方法
  void updateDashOffset() {
    _dashOffset += 0.5; // 控制滚动速度
    if (_dashOffset > 100) _dashOffset = 0;
    notifyListeners();
  }

  /// 处理节点拖拽
  /// [tag] 被拖拽节点的标签
  /// [delta] 手指滑动的偏移增量 (details.delta)
  void updateNodePosition(String tag, Offset delta) {
    final index = nodes.indexWhere((n) => n.tag == tag);
    if (index < 0) {
      print('Node with tag $tag not found');
      return;
    }
    final node = nodes[index];
    // 计算新位置
    Offset newPosition = node.style.position + delta;

    // 【可选】边缘限制逻辑
    // 如果你想让节点中心不超出画布，可以这样限制：

    newPosition = Offset(
      newPosition.dx.clamp(-canvasSize.width / 2, canvasSize.width / 2),
      newPosition.dy.clamp(-canvasSize.height / 2, canvasSize.height / 2),
    );

    node.style.position = newPosition;
    notifyListeners();
  }
}
