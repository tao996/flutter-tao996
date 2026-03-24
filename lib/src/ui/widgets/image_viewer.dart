import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tao996/tao996.dart';

/// 多张图片浏览：
/// 在 MyImageViewerWidget 的基础上，添加了向左滑（下一张）和向右滑（上一张）的功能
/// [imageUrls] 待浏览的图片的列表；[index] 默认显示的图片索引； [director] 如果用户需要保存，则保存到该目录下; [actions] 底部操作按钮
// void openImagesViewer(
//   BuildContext context,
//   List<String> imageUrls, {
//   int index = 0,
//   Directory? director,
//   List<Widget>? actions,
// }) {
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => MyImagesViewerWidget(
//         imageUrls: imageUrls,
//         index: index,
//         director: director,
//         actions: actions,
//       ),
//     ),
//   );
// }

/// 打开图片 [imageUrl] 图片路径; [director] 如果用户需要保存，则保存到该目录下; [actions] 底部操作按钮
void openImageViewer(
  BuildContext context,
  String imageUrl, {
  Directory? director,
  List<Widget>? actions,
}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => _MyImageViewer(
        imageUrl: tu.path.normalize(imageUrl),
        director: director,
        actions: actions,
      ),
    ),
  );
}

class _MyImageViewer extends StatefulWidget {
  /// 图片的访问地址
  final String imageUrl;

  /// 缓存到本地保存的目录
  final Directory? director;

  /// 底部操作按钮
  final List<Widget>? actions;

  const _MyImageViewer({required this.imageUrl, this.director, this.actions});

  @override
  State<_MyImageViewer> createState() => _MyImageViewerState();
}

class _MyImageViewerState extends State<_MyImageViewer> {
  late ResourceLocation location;
  late String imageUrl;

  @override
  void initState() {
    super.initState();
    _updateImageUrl(widget.imageUrl);
  }

  void _updateImageUrl(String newImageUrl) {
    setState(() {
      location = tu.path.determineLocation(newImageUrl);
      imageUrl = newImageUrl;
    });
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
                        File(imageUrl),
                        fit: BoxFit.contain,

                        // 专门处理异步加载失败（文件不存在或被清除）
                        errorBuilder: (context, error, stackTrace) {
                          // 捕获到加载失败，打印错误
                          dprint('异步加载图片失败失败，触发再生或显示错误图标: $imageUrl');
                          dprint('具体错误: $error');

                          // 返回一个替代的 Widget
                          return const Center(
                            child: Icon(Icons.broken_image, color: Colors.red),
                          );
                        },
                      )
                    : CachedNetworkImage(
                        imageUrl: imageUrl,
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
              opacity: 1.0,
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
                      onTap: () => _downloadImage(
                        imageUrl: imageUrl,
                        location: location,
                        director: widget.director,
                      ),
                      vertical: false,
                    ),

                    imageViewerActionButton(
                      icon: Icons.share,
                      label: 'share'.tr,
                      onTap: () => _shareImage(
                        imageUrl: imageUrl,
                        location: location,
                        director: widget.director,
                      ),
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
                opacity: 1.0,
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

/// 获取图片文件
Future<File?> _getImage({
  required String imageUrl,
  required ResourceLocation location,
  Directory? director,
  void Function(int, int)? onReceiveProgress,
}) async {
  if (location.isLocal) {
    return File(imageUrl);
  }
  final directory =
      director ?? await getIPathService().getTemporaryDirectoryPath();
  // 从 URL 中提取文件名，或者生成一个唯一的文件名
  final fileName = imageUrl.split('/').last.split('?').first;
  final filePath = '${directory.path}/$fileName';

  final file = File(filePath);
  // 检查图片是否存在
  if (file.existsSync()) {
    dprint('图片已经存在本地: $filePath');
  } else {
    final success = await getIDioHttpService().download(imageUrl, filePath);
    if (success) {
      dprint('图片已经下载到本地: $filePath');
    } else {
      return null;
    }
  }
  return file;
}

/// 下载图片
Future<void> _downloadImage({
  required String imageUrl,
  required ResourceLocation location,
  Directory? director,
}) async {
  try {
    if (Platform.isAndroid) {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        await tu.sd.alert('permissionStorageDeny'.tr);
        return;
      }
    }
    if (location.isLocal) {
      await tu.file.saveFileToGallery(imageUrl);
    } else {
      final file = await _getImage(
        imageUrl: imageUrl,
        location: location,
        director: director,
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
        tu.sd.error('imageDownloadError'.tr);
        return;
      } else {
        await tu.file.saveImageToGallery(file: file);
      }
    }
    tu.sd.success('downloadAndSaveSuccess'.tr);
  } catch (error, stackTrace) {
    getIDebugService().exception(
      error,
      stackTrace,
      errorMessage: 'download failed'.trParams({'reason': error.toString()}),
    );
  }
}

// 分享图片
Future<void> _shareImage({
  required String imageUrl,
  required ResourceLocation location,
  Directory? director,
}) async {
  tu.sd.toast('imageSharing'.tr);
  try {
    final file = await _getImage(
      imageUrl: imageUrl,
      location: location,
      director: director,
    );
    if (file == null) {
      tu.sd.error('imageNotExists'.tr);
      return;
    } else {
      await getIShareService().shareFilepath(file.path);
    }
    // _messageService.showToast(msg: '分享已完成'.tr);

    // 分享完成后，可以选择删除临时文件 (可选，因为是临时目录，系统会清理)
    // File(filePath).deleteSync(); // 如果需要立即删除
    // _debugService.d('临时文件已删除');
  } catch (e) {
    getIDebugService().d('分享图片错误');
    tu.sd.error('shareFailed'.trParams({'reason': e.toString()}));
  }
}
