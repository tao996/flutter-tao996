import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tao996/tao996.dart';

void openImageViewer(
  BuildContext context,
  String imageUrl, {
  Directory? director,
  List<Widget>? actions,
}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MyImageViewerWidget(
        imageUrl: FilepathUtil.normalize(imageUrl),
        director: director,
        actions: actions,
      ),
    ),
  );
}

/// 新增图片查看器页面，在 image.dart 中使用
class MyImageViewerWidget extends StatefulWidget {
  /// 图片的访问地址
  final String imageUrl;

  /// 缓存到本地保存的目录
  final Directory? director;

  final List<Widget>? actions;

  const MyImageViewerWidget({
    super.key,
    required this.imageUrl,
    this.director,
    this.actions,
  });

  @override
  State<MyImageViewerWidget> createState() => _MyImageViewerWidgetState();
}

class _MyImageViewerWidgetState extends State<MyImageViewerWidget> {
  final _debugService = getIDebugService();
  final _messageService = getIMessageService();
  ResourceLocation location = ResourceLocation.unknown;

  @override
  void initState() {
    super.initState();
    location = FilepathUtil.determineLocation(widget.imageUrl);
    dprint('资源位置: ${widget.imageUrl} => $location');
  }

  // 控制底部操作按钮的显示/隐藏状态
  final bool _showControls = true;

  Future<File?> _getImage({void Function(int, int)? onReceiveProgress}) async {
    if (location.isLocal) {
      return File(widget.imageUrl);
    }
    final directory =
        widget.director ?? await getIPathService().getTemporaryDirectoryPath();
    // 从 URL 中提取文件名，或者生成一个唯一的文件名
    final fileName = widget.imageUrl.split('/').last.split('?').first;
    final filePath = '${directory.path}/$fileName';

    final file = File(filePath);
    // 检查图片是否存在
    if (file.existsSync()) {
      dprint('图片已经存在本地: $filePath');
    } else {
      final success = await getIDioHttpService().download(
        widget.imageUrl,
        filePath,
      );
      if (success) {
        dprint('图片已经下载到本地: $filePath');
      } else {
        return null;
      }
    }
    return file;
  }

  // 模拟下载图片功能
  Future<void> _downloadImage() async {
    try {
      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          _debugService.d(
            '存储权限未授予',
            errorMessage: 'Permission storage deny'.tr,
          );
          return;
        }
      }
      if (location.isLocal) {
        await MyFileService.saveFile(widget.imageUrl);
      } else {
        final file = await _getImage(
          onReceiveProgress: (received, total) {
            if (total != -1) {
              double progress = (received / total) * 100;
              // 你可以在这里更新下载进度条，如果需要的话
              if (isDebugMode) {
                dprint('下载进度: ${progress.toStringAsFixed(0)}%');
              }
            }
          },
        );
        if (file == null) {
          _messageService.error('image download error'.tr);
          return;
        } else {
          await MyFileService.saveImage(file);
        }
      }
      _debugService.d('图片保存成功', successMessage: 'download and save success'.tr);
    } catch (error, stackTrace) {
      _debugService.exception(
        error,
        stackTrace,
        errorMessage: 'download failed'.trParams({'reason': error.toString()}),
      );
    }
  }

  // 模拟分享图片功能
  Future<void> _shareImage() async {
    _messageService.toast('image sharing'.tr);
    try {
      final file = await _getImage();
      if (file == null) {
        _messageService.error('image not exists'.tr);
      } else {
        await getIShareService().shareFilepath(file.path);
      }
      // _messageService.showToast(msg: '分享已完成'.tr);

      // 分享完成后，可以选择删除临时文件 (可选，因为是临时目录，系统会清理)
      // File(filePath).deleteSync(); // 如果需要立即删除
      // _debugService.d('临时文件已删除');
    } catch (e) {
      _debugService.d(
        '分享图片错误: $e',
        errorMessage: 'share failed'.trParams({'reason': e.toString()}),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 全屏黑色背景
      body: Stack(
        children: [
          // 1. 可放大缩小的图片区域
          // 使用 Stack 包裹 GestureDetector 以便点击图片关闭页面
          Positioned.fill(
            child: GestureDetector(
              // 点击图片任意位置即可关闭页面
              onTap: () {
                Navigator.pop(context); // 点击图片后，自动关闭当前图片浏览器
              },
              // 确保 InteractiveViewer 自身也能响应点击，但这里我们让 GestureDetector 优先
              // 如果 InteractiveViewer 内部有复杂手势，可能需要调整
              child: InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(1),
                minScale: 1, // 适当的最小缩放
                maxScale: 10, // 适当的最大缩放
                child: location.isLocal
                    ? Image.file(
                        File(widget.imageUrl),
                        fit: BoxFit.contain,

                        // 专门处理异步加载失败（文件不存在或被清除）
                        errorBuilder: (context, error, stackTrace) {
                          // 捕获到加载失败，打印错误
                          dprint('异步加载图片失败失败，触发再生或显示错误图标: ${widget.imageUrl}');
                          dprint('具体错误: $error');

                          // 返回一个替代的 Widget
                          return const Center(
                            child: Icon(Icons.broken_image, color: Colors.red),
                          );
                        },
                      )
                    : CachedNetworkImage(
                        imageUrl: widget.imageUrl,
                        fit: BoxFit.contain, // 确保图片完整显示
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(
                            Icons.error,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),
              ),
            ),
          ),

          // 2. 顶部返回按钮 (模仿 AppBar 但更灵活)
          Positioned(
            top: MediaQuery.of(context).padding.top, // 距离状态栏顶部
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                color: Colors.black.withAlpha(120), // 半透明背景
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Spacer(), // 将返回按钮推到左边
                    // 如果有其他顶部操作，可以放在这里
                    imageViewerActionButton(
                      icon: Icons.download,
                      label: '下载',
                      onTap: _downloadImage,
                      vertical: false,
                    ),

                    imageViewerActionButton(
                      icon: Icons.share,
                      label: 'Share'.tr,
                      onTap: _shareImage,
                      vertical: false,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. 底部操作按钮
          if (widget.actions != null && widget.actions!.isNotEmpty)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom, // 距离系统导航栏底部
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  color: Colors.black.withAlpha(120), // 半透明背景
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround, // 按钮均匀分布
                    children: widget.actions!,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 辅助方法：构建底部操作按钮
Widget imageViewerActionButton({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  bool vertical = true,
}) {
  if (vertical == false) {
    return TextButton.icon(
      onPressed: onTap,
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12.0),
      ),
      icon: Icon(icon, color: Colors.white),
    );
  }
  return Column(
    children: [
      IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onTap,
      ),
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 12.0)),
    ],
  );
}
