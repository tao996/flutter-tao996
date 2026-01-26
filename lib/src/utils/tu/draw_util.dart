import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';

class DrawUtil {
  const DrawUtil();

  /// 1. 渲染本地图片：直接通过磁盘字节流生成 ui.Image
  /// 所有的 `ui.Image` 和 `ui.Picture` 都是 Native 对象，注意在使用完后（比如图层刷新或页面销毁时）手动调用 image.dispose()。
  Future<ui.Image> renderImage(String path) async {
    final bytes = await File(path).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  /// 2. 渲染网络 SVG
  Future<ui.Image> renderSvgWithUrl(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) throw Exception('Download failed');
    return await renderSvg(response.body);
  }

  /// 3. 渲染 SVG 字符串：直接通过 Picture 转换，不再经过 PNG 中转
  // Future<ui.Image> renderSvg(
  //   String svgContent, {
  //   Size size = const Size(512, 512),
  // }) async {
  //   final pictureInfo = await vg.loadPicture(SvgStringLoader(svgContent), null);
  //   // 直接在 GPU 录制 picture 并转为 image
  //   final image = await pictureInfo.picture.toImage(
  //     size.width.toInt(),
  //     size.height.toInt(),
  //   );

  //   print("SVG 加载成功: ${pictureInfo.size} -> (${image.width},${image.height})");

  //   pictureInfo.picture.dispose(); // 及时释放 picture
  //   return image;
  // }

  Future<ui.Image> renderSvg(
    String svgContent, {
    Size size = const Size(512, 512),
  }) async {
    // 1. 加载 Picture
    final pictureInfo = await vg.loadPicture(SvgStringLoader(svgContent), null);

    // 2. 获取 SVG 的原始尺寸 (来自 viewBox 或 width/height)
    // 如果没有获取到，默认使用 512
    final double rawWidth = pictureInfo.size.width > 0
        ? pictureInfo.size.width
        : 512;
    final double rawHeight = pictureInfo.size.height > 0
        ? pictureInfo.size.height
        : 512;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // 3. 计算缩放比例，实现 BoxFit.contain 效果
    final double scaleX = size.width / rawWidth;
    final double scaleY = size.height / rawHeight;
    // 如果想保持等比缩放不拉伸，取两者中的最小值
    // final double scale = scaleX < scaleY ? scaleX : scaleY;
    // canvas.scale(scale, scale);

    // 强制拉伸到目标 Size
    canvas.scale(scaleX, scaleY);

    // 4. 绘制到 Recorder
    canvas.drawPicture(pictureInfo.picture);

    // 5. 转换为 ui.Image
    final image = await recorder.endRecording().toImage(
      size.width.toInt(),
      size.height.toInt(),
    );

    pictureInfo.picture.dispose();
    return image;
  }

  /// 4. 渲染文字：利用原生 Canvas 绘制，效果等同于超采样，但效率更高
  Future<ui.Image> renderText(
    String text, {
    required Size size,
    double? fontSize,
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
    double pixelRatio = 3.0,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // 缩放画布以匹配高分辨率
    canvas.scale(pixelRatio);

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize ?? size.width,
          color: color ?? Colors.black,
          fontWeight: fontWeight,
          height: 1.0,
          // 移除 height: 1.0，让字体回归自然行高
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    // 必须先布局，才能拿到 tp.width 和 tp.height
    tp.layout(maxWidth: size.width);

    // 计算垂直居中的偏移量
    // dy = (容器总高度 - 文字实际排版高度) / 2
    final double dy = (size.height - tp.height) / 2;

    // 如果你希望左右也居中，可以设置 dx = (size.width - tp.width) / 2
    // 如果希望左对齐，dx 则为 0
    final double dx = (size.width - tp.width) / 2;

    // dprint(
    //   'text:$text --- size($size), tp(${tp.width}, ${tp.height}, d($dx, $dy))',
    // );
    // 关键绘制：传入计算好的 Offset
    tp.paint(canvas, Offset(dx, dy));
    // tp.paint(canvas, Offset.zero);

    final picture = recorder.endRecording();
    return await picture.toImage(
      (size.width * pixelRatio).toInt(),
      (size.height * pixelRatio).toInt(),
    );
  }
}
