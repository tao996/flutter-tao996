import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// 具有缓存功能的图片组件
/// [data] 图片地址（网络或者本地）
class MyImageCache extends StatefulWidget {
  final dynamic data;
  final void Function()? onTap;
  final bool enabledTap;
  final double? size;

  const MyImageCache({
    super.key,
    required this.data,
    this.onTap,
    this.enabledTap = true,
    this.size,
  });

  @override
  State<MyImageCache> createState() => _MyImageCacheState();
}

// 总是加载图片：1 wifi + 关闭了数据流量模式；2 图片缓存
// 条件加载： 开启流量模式 + wifi
class _MyImageCacheState extends State<MyImageCache> {
  final IDebugService _debugService = getIDebugService();

  /// 是否为设备资源
  bool _isDeviceResource = false;
  bool _isAssetsResource = false;
  bool _isIconResource = false;
  bool _isSvgResource = false;

  /// 是否开启流量模式
  bool _useLowDataMode = true;

  /// 是否为高速网络
  bool _isSpeedNetwork = false;

  /// 条件加载
  bool _shouldLoadManually = false;

  /// 图片缓存
  bool _isImageCached = false;

  String imageUrl = '';

  _MyImageCacheState() {}

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      if ((widget.data as String).startsWith('assets/') ||
          (widget.data as String).startsWith('packages/')) {
        _isAssetsResource = true;
        _isDeviceResource = true;
      } else if (widget.data is IconData) {
        _isIconResource = true;
        _isDeviceResource = true;
      } else {
        _isDeviceResource = tu.path.isAbsolute(widget.data!);
      }
    }

    if (_isDeviceResource) {
      // dprint('设备图片');
    } else {
      _useLowDataMode = getISettingsService().useLowDataMode;
      _isSpeedNetwork = getINetworkService().isSpeedNetwork;

      /// 是否需要手动加载
      _shouldLoadManually = _useLowDataMode && !_isSpeedNetwork;
      _debugService.d(
        '[_MyImageCacheState] 图片加载模式',
        args: {
          "useLowDataMode": _useLowDataMode,
          "isSpeedNetwork": _isSpeedNetwork,
          "shouldLoadManually": _shouldLoadManually,
        },
      );
    }
    if (!_isDeviceResource) {
      if (widget.data != null) {
        imageUrl = widget.data!.startsWith('//')
            ? 'https:${widget.data}'
            : widget.data!;
      }
      _checkImageCache(); // 首次检查缓存
    }
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
    if (_isDeviceResource) {
      if (_isAssetsResource || _isIconResource || _isSvgResource) {
        return _gestureDetector(
          context,
          MyIconSvg(widget.data, size: widget.size),
          imageUrl: widget.data!,
        );
      }
      return _gestureDetector(
        context,
        tu.image.deviceImage(
          widget.data!,
          width: widget.size,
          height: widget.size,
        ),
        imageUrl: widget.data!,
      );
    }
    // 没有 URL 无需加载
    if (imageUrl.isEmpty) {
      return const SizedBox.shrink(); // 没有 URL，不显示任何内容
    }
    // 已缓存，总是立即加载
    if (_isImageCached || _shouldLoadManually) {
      return _gestureDetector(
        context,
        tu.image.networkImage(
          imageUrl,
          width: widget.size,
          height: widget.size,
        ),
        imageUrl: imageUrl,
      );
    }
    // wifi，图片可见时加载
    if (_isSpeedNetwork) {
      return _visibilityDetector(context, imageUrl);
    }
    // 没有网络
    if (getINetworkService().isNoNetwork) {
      return tu.image.placeholder('No network'.tr);
    }

    return tu.image.placeholder(
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
      child: _gestureDetector(
        context,
        tu.image.networkImage(
          imageUrl,
          width: widget.size,
          height: widget.size,
        ),
        imageUrl: imageUrl,
      ),
    );
  }

  /// 图片点击事件
  Widget _gestureDetector(
    BuildContext context,
    Widget child, {
    required String imageUrl,
  }) {
    if (!widget.enabledTap) {
      return child;
    }
    return GestureDetector(
      // <--- 添加 GestureDetector
      onTap: () {
        if (imageUrl.isNotEmpty) {
          // 只有在图片应该加载时才允许点击放大
          if (widget.onTap != null) {
            widget.onTap!();
          } else {
            openImageViewer(context, imageUrl);
          }
        }
      },
      child: child,
    );
  }
}
