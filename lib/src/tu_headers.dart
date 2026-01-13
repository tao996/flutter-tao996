
///
/// [network]  HTTP/HTTPS 等网络协议；
/// [local]  file:// 协议或看起来像一个无协议的本地路径；
/// [assets]  Flutter 中的 Asset 资源；
/// [unknown] 无法判断；
enum ResourceLocation { local, network, assets, unknown }

extension ResourceLocationExtension on ResourceLocation {
  bool get isLocal => this == ResourceLocation.local;

  bool get isNetwork => this == ResourceLocation.network;

  bool get isAssets => this == ResourceLocation.assets;

  bool get isUnknown => this == ResourceLocation.unknown;
}

/// 选择类型 [camera] 拍照；[gallery] 相册；[galleryVideo] 从相册选择一个视频；[cameraVideo] 拍摄一个视频；[media] 选择一个图片和视频
enum ImagePickerSource { camera, gallery, galleryVideo, cameraVideo, media }

enum ImagePickerMultipleSource { image, medio, video }

enum DateTimeFormat { ym, ymd, ymdHm, ymdHms, ymdFile, ymdHmFile, ymdHmsFile }


class MyPaginationParams {
  /// 每页默认记录数。
  static const int defaultPageSize = 15;

  /// 当前页面，最小值为1
  final int page;

  /// 每页记录数，最小值为1。
  final int pageSize;

  /// 是否启用分页。如果为 false，则可能返回所有数据
  final bool enablePagination;

  /// 构造函数。
  /// [page] 默认为1。
  /// [pageSize] 如果传入0或负数，将使用 [defaultPageSize]。
  /// [enablePagination] 默认为 true。
  MyPaginationParams({
    this.page = 1,
    int pageSize = 0,
    this.enablePagination = true,
  }) : pageSize = pageSize > 0 ? pageSize : defaultPageSize;

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'pageSize': pageSize,
      'enablePagination': enablePagination,
    };
  }
}

/// 标准 API 响应结构。
/// 包含状态码、消息和实际数据
class MyApiResponse {
  final int code;
  final String message;
  final dynamic data;

  MyApiResponse({required this.code, required this.message, required this.data});

  factory MyApiResponse.fromJson(Map<String, dynamic> json) {
    return MyApiResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }

  /// 判断 API 请求是否成功。
  /// 约定 code 为 0 或 200 表示成功。
  bool isSuccess() {
    // 更名为 isSuccess 更符合命名习惯
    return code == 0 || code == 200;
  }
}

class MyPaginatedResponse<T> {
  /// 总记录数。
  final int totalCount;

  /// 当前页的记录列表。
  final List<T>? items;

  static String mapTotalCountName = 'totalCount';
  static String mapItemsName = 'list';

  MyPaginatedResponse({required this.totalCount, this.items});

  /// 从 JSON Map 创建 PaginatedResponse 实例。
  /// [itemBuilder] 是一个函数，用于将 `List<Map<String, dynamic>>` 转换为 `List<T>`。
  factory MyPaginatedResponse.fromJson(
      Map<String, dynamic> json,
      List<T> Function(List<Map<String, dynamic>>)? itemBuilder,
      ) {
    return MyPaginatedResponse(
      totalCount: (json[mapTotalCountName] as num? ?? 0).toInt(),
      // 更安全的类型转换和默认值
      items:
      (json[mapItemsName] == null || itemBuilder == null) // 字段名改为 'list'
          ? null
          : itemBuilder(
        (json[mapItemsName] as List).cast<Map<String, dynamic>>(),
      ),
    );
  }
}

/// 自定义异常类，用于表示 API 请求或响应中的错误。
class MyApiException implements Exception {
  final String message;

  MyApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}