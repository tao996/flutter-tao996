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
  Future<ui.Image> renderSvg(
    String svgContent, {
    Size size = const Size(512, 512),
  }) async {
    final pictureInfo = await vg.loadPicture(SvgStringLoader(svgContent), null);

    // 直接在 GPU 录制 picture 并转为 image
    final image = await pictureInfo.picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );

    pictureInfo.picture.dispose(); // 及时释放 picture
    return image;
  }

  /// 4. 渲染文字：利用原生 Canvas 绘制，效果等同于超采样，但效率更高
  Future<ui.Image> renderText(
    String text, {
    required Size size,
    String? fontFamily,
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
    double pixelRatio = 3.0, // 替代原本的 scale，根据设备像素比调整清晰度
  }) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    // 这里的 scale 只是为了增加位图的分辨率，保证缩放时不糊
    canvas.scale(pixelRatio);

    final textStyle = TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize ?? size.width,
      color: color ?? Colors.black,
      fontWeight: fontWeight,
      height: 1.0,
    );

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: size.width);

    // 在 DrawUtil.renderText 中
    // 修改前 居中：final offset = Offset((size.width - tp.width)/2, (size.height - tp.height)/2);
    // 修改后：直接使用 Offset.zero，让文字从左上角开始绘制

    textPainter.paint(canvas, Offset.zero);

    final picture = pictureRecorder.endRecording();
    // 生成对应倍率大小的图片
    final uiImage = await picture.toImage(
      (size.width * pixelRatio).toInt(),
      (size.height * pixelRatio).toInt(),
    );

    picture.dispose();
    return uiImage;
  }
}
