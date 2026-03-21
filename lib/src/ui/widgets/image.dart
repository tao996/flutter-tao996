import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../../tao996.dart';

/// 图片占位符
Widget myImagePlaceholder(String text, {void Function()? onTap}) {
  return Center(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[200],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.broken_image_outlined),
            const SizedBox(height: 8),
            Text(text),
          ],
        ),
      ),
    ),
  );
}

class MyImageCache extends StatefulWidget {
  final String? url;

  const MyImageCache({super.key, required this.url});

  @override
  State<MyImageCache> createState() => _MyImageCacheState();
}

// 总是加载图片：1 wifi + 关闭了数据流量模式；2 图片缓存
// 条件加载： 开启流量模式 + wifi
class _MyImageCacheState extends State<MyImageCache> {
  final IDebugService _debugService = getIDebugService();

  /// 是否
  final bool useLowDataMode;
  final bool isWifi;

  _MyImageCacheState()
    : useLowDataMode = getISettingsService().useLowDataMode,
      isWifi = getINetworkService().isSpeedNetwork {
    _shouldLoadManually = useLowDataMode && !isWifi;
    _debugService.d(
      '[_MyImageCacheState] 图片加载模式',
      args: {
        "useLowDataMode": useLowDataMode,
        "isWifi": isWifi,
        "shouldLoadManually": _shouldLoadManually,
      },
    );
  }

  /// 条件加载
  bool _shouldLoadManually = false;

  /// 图片缓存
  bool _isImageCached = false;

  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    if (widget.url != null) {
      imageUrl = widget.url!.startsWith('//')
          ? 'https:${widget.url}'
          : widget.url!;
    }

    _checkImageCache(); // 首次检查缓存
  }

  // 检查图片是否在缓存中
  Future<void> _checkImageCache() async {
    if (imageUrl.isEmpty) {
      if (mounted) {
        setState(() {
          _isImageCached = false;
        });
      }
      dprint('[checkImageCache] imageUrl is empty');
      return;
    }
    try {
      dprint('[checkImageCache] 准备检查 URL 缓存: $imageUrl');
      final cacheManager = DefaultCacheManager();

      final file = await cacheManager.getFileFromCache(imageUrl);
      if (mounted) {
        setState(() {
          _isImageCached = file != null;
        });
        dprint('[checkImageCache] 缓存文件是否存在: $_isImageCached');
      }
    } catch (e) {
      dprint('[checkImageCache] 检查缓存时发生错误: $imageUrl, 错误: $e');

      if (mounted) {
        setState(() {
          _isImageCached = false; // 出错时假设未缓存
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 没有 URL 无需加载
    if (imageUrl.isEmpty) {
      return const SizedBox.shrink(); // 没有 URL，不显示任何内容
    }
    // 已缓存，总是立即加载
    if (_isImageCached || _shouldLoadManually) {
      return _gestureDetector(context, _image(imageUrl), imageUrl: imageUrl);
    }
    // wifi，图片可见时加载
    if (isWifi) {
      return _visibilityDetector(context, imageUrl);
    }
    // 没有网络
    if (getINetworkService().isNoNetwork) {
      return myImagePlaceholder('No network'.tr);
    }

    return myImagePlaceholder(
      'clickToLoadImage'.tr,
      onTap: () {
        // 点击时，允许立即加载
        setState(() {
          _shouldLoadManually = true;
        });
      },
    );
  }

  /// 图片可见区域检测
  Widget _visibilityDetector(BuildContext context, String imageUrl) {
    return VisibilityDetector(
      key: Key(imageUrl), // 为每个图片 URL 使用唯一的 key
      onVisibilityChanged: (VisibilityInfo info) {
        // 如果图片可见，CachedNetworkImage 会自动处理加载。
        // 这里不需要额外的 _isVisible 状态。
        // 可以用于调试或更复杂的懒加载策略（例如，当图片进入屏幕时预加载）
        if (isDebugMode && info.visibleFraction > 0.0) {
          dprint(
            '[VisibilityDetector]: $imageUrl isVisible: ${info.visibleFraction}',
          );
        }
      },
      child: _gestureDetector(context, _image(imageUrl), imageUrl: imageUrl),
    );
  }

  /// 图片点击事件
  Widget _gestureDetector(
    BuildContext context,
    Widget child, {
    required String imageUrl,
  }) {
    return GestureDetector(
      // <--- 添加 GestureDetector
      onTap: () {
        if (imageUrl.isNotEmpty) {
          // 只有在图片应该加载时才允许点击放大
          openImageViewer(context, imageUrl);
        }
      },
      child: child,
    );
  }

  /// 显示指定图片
  /// [imageUrl] 图片地址
  Widget _image(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      // 占位符和错误组件处理它们自己的状态
      placeholder: (context, url) => myImagePlaceholder('imageLoading'.tr),
      errorWidget: (context, url, error) =>
          myImagePlaceholder('imageLoadError'.tr),
      fadeInDuration: const Duration(milliseconds: 500),
      fadeOutDuration: const Duration(milliseconds: 500),
    );
  }
}

// 这是一个示例 Widget，您可以在您的 Tile 或其他地方使用它
class MyFixedSizeLocalImage extends StatelessWidget {
  final String filePath;
  final double width;
  final double height;

  const MyFixedSizeLocalImage({
    super.key,
    required this.filePath,
    this.width = 50,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    // 确保文件路径不为空且不是一个占位符
    if (filePath.isEmpty) {
      return const SizedBox(
        width: 50,
        height: 50,
        child: Icon(Icons.broken_image, size: 30),
      );
    }

    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.hardEdge,
      // 确保图片不会溢出边界
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4), // 可选：添加圆角
      ),
      child: Image.file(
        File(filePath), // 1. 使用 Image.file 加载本地文件

        width: width, // 2. 限制图片的宽度
        height: height, // 3. 限制图片的高度
        // 4. 控制图片的填充方式
        fit: BoxFit.cover,

        // 5. 推荐：处理图片加载失败的情况 (文件不存在、损坏等)
        errorBuilder: (context, error, stackTrace) {
          // 在文件不存在或加载失败时，显示一个占位符
          return const Center(
            child: Icon(
              Icons.image_not_supported,
              size: 30,
              color: Colors.grey,
            ),
          );
        },
      ),
    );
  }
}
