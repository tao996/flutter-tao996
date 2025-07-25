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
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
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
  final NetworkState networkState; // 网络状态：如果是 wifi 则直接加载图片
  final bool useLowDataMode; // 低流量模式：如果图片没有缓存，并且网络可连接时，则需要用户手动点击后才下载显示

  const MyImageCache({
    super.key,
    required this.url,
    required this.networkState,
    required this.useLowDataMode,
  });

  @override
  State<MyImageCache> createState() => _MyImageCacheState();
}

// 总是加载图片：1 wifi + 关闭了数据流量模式；2 图片缓存
// 条件加载： 开启流量模式 + wifi
class _MyImageCacheState extends State<MyImageCache> {
  // 条件加载
  bool _shouldLoadManually = false;

  // 图片缓存
  bool _isImageCached = false;

  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    if (widget.url != null) {
      imageUrl =
          widget.url!.startsWith('//') ? 'https:${widget.url}' : widget.url!;
    }
    _shouldLoadManually = widget.useLowDataMode && !widget.networkState.isWifi;
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
      return;
    }
    try {
      // **关键改进：直接使用 DefaultCacheManager.instance**
      // 这是 CachedNetworkImage 默认使用的缓存管理器实例
      final cacheManager = DefaultCacheManager();
      if (isDebugMode) {
        getIDebugService().d('[_checkImageCache] 正在检查 URL 缓存: $imageUrl');
      }

      final file = await cacheManager.getFileFromCache(imageUrl);

      if (mounted) {
        setState(() {
          _isImageCached = file != null;
        });
        if (isDebugMode) {
          getIDebugService().d('[_checkImageCache] 缓存文件是否存在: $_isImageCached');
        }
      }
    } catch (e) {
      if (isDebugMode) {
        getIDebugService().d('[_checkImageCache] 检查缓存时发生错误: $imageUrl, 错误: $e');
      }
      if (mounted) {
        setState(() {
          _isImageCached = false; // 出错时假设未缓存
        });
      }
    }
  }

  // 处理 widget 更新如果参数更改 (例如，widget 存活时网络状态更改)
  @override
  void didUpdateWidget(covariant MyImageCache oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果低流量模式改变或网络状态改变，重新评估 _shouldLoadManually 和缓存状态
    if (widget.useLowDataMode != oldWidget.useLowDataMode ||
        widget.networkState != oldWidget.networkState ||
        imageUrl !=
            oldWidget
                .url // URL 变化也需要重新检查缓存
                ) {
      // 仅当新状态符合“需要手动加载”的条件时，才将其重置为 true
      // 否则，如果之前已经手动加载了，或者条件不再满足，就保持为 false
      bool newShouldLoadManually =
          widget.useLowDataMode && !widget.networkState.isWifi;
      setState(() {
        if (newShouldLoadManually && !_isImageCached) {
          // 仅当满足手动加载条件且图片未缓存时才设置
          _shouldLoadManually = true;
        } else {
          _shouldLoadManually = false; // 其他情况下，图片应该自动加载
        }
      });
      _checkImageCache(); // 重新检查缓存
    }
  }

  // 这个辅助函数根据所有条件判断图片是否应该立即加载
  bool _shouldLoadImageImmediately() {
    // 1. 没有 URL，无需加载
    if (imageUrl.isEmpty) return false;

    // 2. 如果已缓存，总是立即加载 (即使在低流量模式下)
    if (_isImageCached) return true;

    // 3. 如果是 Wi-Fi，总是立即加载
    if (widget.networkState.isWifi) {
      return true;
    }

    // 4. 如果低流量模式关闭，总是立即加载
    if (!widget.useLowDataMode) {
      return true;
    }

    // 5. 如果以上条件都不满足 (即低流量模式开启且不是 Wi-Fi 且未缓存)，
    //    则只有当用户手动点击后才加载。
    return _shouldLoadManually;
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return const SizedBox.shrink(); // 没有 URL，不显示任何内容
    }

    // 根据当前逻辑判断图片是否应该立即加载
    final bool loadImmediately = _shouldLoadImageImmediately();

    // 调试日志
    if (isDebugMode) {
      getIDebugService().d(
        '[MyImageCache] URL: $imageUrl, 网络: ${widget.networkState.name}, '
        '低流量模式: ${widget.useLowDataMode}, 已缓存: $_isImageCached, '
        '应手动加载: $_shouldLoadManually, 立即加载: $loadImmediately',
      );
    }

    // 如果处于低流量模式 (且不是 Wi-Fi) 并且图片未缓存 并且用户尚未点击
    if (widget.useLowDataMode &&
        !widget.networkState.isWifi &&
        !_isImageCached &&
        !_shouldLoadManually) {
      if (widget.networkState.isNoNetwork) {
        return myImagePlaceholder('No network'.tr);
      }
      return myImagePlaceholder(
        'Click to load image'.tr,
        onTap: () {
          // 点击时，允许立即加载
          setState(() {
            _shouldLoadManually = true;
          });
        },
      );
    }

    // 否则，继续渲染图片或其占位符 (由 CachedNetworkImage 管理)
    return GestureDetector(
      // <--- 添加 GestureDetector
      onTap: () {
        if (imageUrl.isNotEmpty && loadImmediately) {
          // 只有在图片应该加载时才允许点击放大
          getIDebugService().d('click to open image view: $imageUrl');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageViewerPage(imageUrl: imageUrl),
            ),
          );
        }
      },
      child: VisibilityDetector(
        key: Key(imageUrl), // 为每个图片 URL 使用唯一的 key
        onVisibilityChanged: (VisibilityInfo info) {
          // 如果图片可见，CachedNetworkImage 会自动处理加载。
          // 这里不需要额外的 _isVisible 状态。
          // 可以用于调试或更复杂的懒加载策略（例如，当图片进入屏幕时预加载）
          if (isDebugMode && info.visibleFraction > 0.0) {
            getIDebugService().d(
              '[VisibilityDetector]: $imageUrl isVisible: ${info.visibleFraction}',
            );
          }
        },
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          // 占位符和错误组件处理它们自己的状态
          placeholder: (context, url) => myImagePlaceholder('image loading'.tr),
          errorWidget:
              (context, url, error) =>
                  myImagePlaceholder('image load error'.tr),
          fadeInDuration: const Duration(milliseconds: 500),
          fadeOutDuration: const Duration(milliseconds: 500),
        ),
      ),
    );
  }
}
