import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageUtil {
  const ImageUtil();

  void open(String imageUrl, {BuildContext? context}) {
    openImageViewer(context ?? Get.context!, imageUrl);
  }

  Widget avatar(
    BuildContext context, {
    String? name,
    String? pathImage,
    double radius = 60,
  }) {
    if (pathImage != null && pathImage.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(File(pathImage)),
      );
    }
    // 默认的首字母头像，沿用抽屉的设计风格
    if (name != null && name.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Text(
          name[0],
          style: TextStyle(
            fontSize: max(radius - 10, 20),
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }

  /// 图片展示组件 - 左侧小图片，右侧上传/移除按钮
  /// 适用于单张图片的上传管理场景
  ///
  /// [imagePath] 本地图片路径
  /// [imageUrl] 网络图片地址（与 imagePath 二选一）
  /// [onUpload] 点击上传按钮的回调
  /// [onRemove] 点击移除按钮的回调
  /// [width] 图片宽度
  /// [height] 图片高度
  /// [borderRadius] 图片圆角
  /// [uploadLabel] 上传按钮文字
  /// [removeLabel] 移除按钮文字
  /// [showUploadButton] 是否显示上传按钮
  /// [showRemoveButton] 是否显示移除按钮（有图片时显示）
  Widget formInput({
    String? imagePath,
    String? imageUrl,
    void Function(String)? onUpload,
    VoidCallback? onRemove,
    VoidCallback? onPressed,
    double width = 80,
    double height = 80,
    double borderRadius = 8,
    String? uploadLabel,
    String? removeLabel,
    bool showUploadButton = true,
    bool showRemoveButton = true,

    bool enableCrop = false, // 是否启用裁剪
    double? cropAspectRatioX = 1, // 裁剪比例 X（如 1 表示正方形）
    double? cropAspectRatioY = 1, // 裁剪比例 Y（如 1 表示正方形）
  }) {
    final hasImage =
        (imagePath != null && imagePath.isNotEmpty) ||
        (imageUrl != null && imageUrl.isNotEmpty);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 左侧：图片预览
        MyEvents.inkWell(
          onTap: () {
            if (imagePath != null && imagePath.isNotEmpty) {
              open(imagePath);
            }
          },
          child: _buildImageWidget(
            imagePath: imagePath,
            imageUrl: imageUrl,
            width: width,
            height: height,
            borderRadius: borderRadius,
          ),
        ),

        const Spacer(),
        // 右侧：操作按钮
        if (showUploadButton)
          IconButton(
            onPressed: () async {
              // 图片选择
              final path = await tu.file.taskPath(
                source: ImagePickerSource.gallery,
              );
              if (path == null || path.isEmpty) {
                return;
              }

              final croppedPath = await _cropImage(
                path,
                aspectRatioX: cropAspectRatioX,
                aspectRatioY: cropAspectRatioY,
              );
              if (croppedPath != null && croppedPath.isNotEmpty) {
                // 图片已裁剪
                onUpload?.call(croppedPath);
              }
            },
            icon: const Icon(Icons.upload),
          ),
        if (showUploadButton && hasImage && showRemoveButton)
          const SizedBox(height: 8),
        if (hasImage && showRemoveButton)
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline),
          ),
      ],
    );
  }

  /// 构建图片 Widget
  Widget _buildImageWidget({
    String? imagePath,
    String? imageUrl,
    required double width,
    required double height,
    required double borderRadius,
  }) {
    // 优先显示本地图片
    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.file(
            file,
            width: width,
            height: height,
            fit: BoxFit.cover,
          ),
        );
      }
    }

    // 其次显示网络图片
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) => _buildPlaceholder(
            width: width,
            height: height,
            borderRadius: borderRadius,
          ),
        ),
      );
    }

    // 显示占位符
    return _buildPlaceholder(
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }

  /// 构建占位符
  Widget _buildPlaceholder({
    required double width,
    required double height,
    required double borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Icon(Icons.image_outlined, size: 32, color: Colors.grey[400]),
    );
  }

  /// 裁剪图片 - 使用 extended_image 提供高级裁剪体验
  Future<String?> _cropImage(
    String sourcePath, {
    double? aspectRatioX,
    double? aspectRatioY,
    String? titleText,
    String? doneButtonText,
    String? cancelButtonText,
  }) async {
    try {
      final result = await Get.to<String?>(
        () => _ImageCropperPage(
          sourcePath: sourcePath,
          aspectRatio: (aspectRatioX != null && aspectRatioY != null)
              ? aspectRatioX / aspectRatioY
              : null,
          titleText: titleText ?? 'cropImage'.tr,
          doneButtonText: doneButtonText ?? 'done'.tr,
          cancelButtonText: cancelButtonText ?? 'cancel'.tr,
        ),
      );
      return result;
    } catch (e) {
      dprint('图片裁剪失败: $e');
      return null;
    }
  }
}

/// 图片裁剪页面 - 使用 extended_image 实现
class _ImageCropperPage extends StatefulWidget {
  final String sourcePath;
  final double? aspectRatio;
  final String titleText;
  final String doneButtonText;
  final String cancelButtonText;

  const _ImageCropperPage({
    required this.sourcePath,
    this.aspectRatio,
    required this.titleText,
    required this.doneButtonText,
    required this.cancelButtonText,
  });

  @override
  State<_ImageCropperPage> createState() => _ImageCropperPageState();
}

class _ImageCropperPageState extends State<_ImageCropperPage> {
  final GlobalKey<ExtendedImageEditorState> editorKey =
      GlobalKey<ExtendedImageEditorState>();
  bool _isSaving = false;
  // 在 State 中定义
  final ImageEditorController _controller = ImageEditorController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titleText),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(result: null),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _cropImage,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    widget.doneButtonText,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
      body: ExtendedImage.file(
        File(widget.sourcePath),
        fit: BoxFit.contain,
        mode: ExtendedImageMode.editor,
        enableLoadState: true,
        cacheRawData: true, // 必须设置为 true 才能获取 rawImageData
        extendedImageEditorKey: editorKey,
        initEditorConfigHandler: (state) {
          return EditorConfig(
            controller: _controller,
            maxScale: 8.0,
            cropRectPadding: const EdgeInsets.all(20.0),
            hitTestSize: 20.0,
            // 裁剪框四角样式
            cornerColor: Colors.white,
            cornerSize: const Size(30, 5),
            lineColor: Colors.white.withValues(alpha: 0.7),
            lineHeight: 1.5,
            editorMaskColorHandler: (context, pointerDown) {
              return Colors.black.withValues(alpha: pointerDown ? 0.4 : 0.6);
            },
            // 设置裁剪比例
            cropAspectRatio: widget.aspectRatio,
            // 允许调整裁剪框
            editActionDetailsIsChanged: (details) {
              // 裁剪框发生变化时的回调
            },
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 旋转按钮
            _buildActionButton(
              icon: Icons.rotate_left,
              label: '旋转',
              onTap: () {
                editorKey.currentState?.rotate();
              },
            ),
            // 重置按钮
            _buildActionButton(
              icon: Icons.restore,
              label: '重置',
              onTap: () {
                editorKey.currentState?.reset();
              },
            ),
            // 比例按钮（如果未锁定比例）
            if (widget.aspectRatio == null)
              _buildActionButton(
                icon: Icons.crop_free,
                label: '自由',
                onTap: () => _showAspectRatioOptions(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _showAspectRatioOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('自由比例'),
                onTap: () {
                  _setCropAspectRatio(null);
                  Get.back();
                },
              ),
              ListTile(
                title: const Text('1:1 正方形'),
                onTap: () {
                  _setCropAspectRatio(1.0);
                  Get.back();
                },
              ),
              ListTile(
                title: const Text('4:3'),
                onTap: () {
                  _setCropAspectRatio(4 / 3);
                  Get.back();
                },
              ),
              ListTile(
                title: const Text('3:4'),
                onTap: () {
                  _setCropAspectRatio(3 / 4);
                  Get.back();
                },
              ),
              ListTile(
                title: const Text('16:9'),
                onTap: () {
                  _setCropAspectRatio(16 / 9);
                  Get.back();
                },
              ),
              ListTile(
                title: const Text('9:16'),
                onTap: () {
                  _setCropAspectRatio(9 / 16);
                  Get.back();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _setCropAspectRatio(double? ratio) {
    _controller.updateCropAspectRatio(ratio); // 使用控制器直接更新
  }

  Future<void> _cropImage() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final state = editorKey.currentState;
      if (state == null || state.rawImageData.isEmpty) {
        Get.back(result: null);
        return;
      }

      // 1. 获取裁剪矩形（注意：此 Rect 是相对于原始图片像素坐标的）
      final Rect? cropRect = state.getCropRect();
      if (cropRect == null) {
        Get.back(result: null);
        return;
      }

      // 2. 获取当前的编辑状态（包含旋转角度等）
      final EditActionDetails action = state.editAction!;

      // 3. 获取原始图片数据
      final Uint8List originImageData = state.rawImageData;

      // 4. 使用 image 库解码
      img.Image? originalImage = img.decodeImage(originImageData);
      if (originalImage == null) {
        Get.snackbar('错误', '无法解码图片');
        return;
      }

      // 5. 处理旋转 (根据文档，使用 action.rotateDegrees 获取角度)
      if (action.hasRotateDegrees) {
        // img 库的旋转是顺时针方向
        originalImage = img.copyRotate(
          originalImage,
          angle: action.rotateDegrees.toInt(),
        );
      }

      // 6. 处理翻转 (Flip)
      if (action.flipY) {
        originalImage = img.flip(
          originalImage,
          direction: img.FlipDirection.horizontal,
        );
      }

      // 7. 执行裁剪
      // 由于 getCropRect() 返回的是相对于处理（旋转/翻转）后的像素坐标，直接使用即可
      final img.Image croppedImage = img.copyCrop(
        originalImage,
        x: cropRect.left.toInt(),
        y: cropRect.top.toInt(),
        width: cropRect.width.toInt(),
        height: cropRect.height.toInt(),
      );

      // 8. 编码为 JPEG
      final Uint8List imageData = Uint8List.fromList(
        img.encodeJpg(croppedImage, quality: 90),
      );

      // 9. 保存到临时文件
      final tempDir = await getTemporaryDirectory();
      final fileName = 'cropped_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(imageData);

      Get.back(result: file.path);
    } catch (e) {
      dprint('裁剪失败: $e');
      Get.snackbar('错误', '裁剪失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
