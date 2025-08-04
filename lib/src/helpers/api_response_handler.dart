import 'package:get/get.dart';

import '../../tao996.dart';

class PaginationParams {
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
  PaginationParams({
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
class ApiResponse {
  final int code;
  final String message;
  final dynamic data;

  ApiResponse({required this.code, required this.message, required this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
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

class PaginatedResponse<T> {
  /// 总记录数。
  final int totalCount;

  /// 当前页的记录列表。
  final List<T>? items;

  static String mapTotalCountName = 'totalCount';
  static String mapItemsName = 'list';

  PaginatedResponse({required this.totalCount, this.items});

  /// 从 JSON Map 创建 PaginatedResponse 实例。
  /// [itemBuilder] 是一个函数，用于将 List<Map<String, dynamic>> 转换为 List<T>。
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    List<T> Function(List<Map<String, dynamic>>)? itemBuilder,
  ) {
    return PaginatedResponse(
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
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

/// 处理 API 响应的通用辅助类。
/// 封装了网络请求、数据解析和错误处理逻辑。
class ApiResponseHandler {
  // 获取服务实例（假设通过依赖注入）
  static final IDebugService _debugService = getIDebugService();

  /// 私有构造函数，防止实例化。
  ApiResponseHandler._();

  /// 获取响应内容，需要自己手动再转换
  static Future<dynamic> getHttpResponseData(
    Future<HttpResponse> Function() apiRequest, {
    int successStatusCode = 200,
  }) async {
    HttpResponse response;
    try {
      response = await apiRequest(); // 调用传入的回调函数执行网络请求
    } catch (error, stackTrace) {
      _debugService.exception(error, stackTrace);
      throw ApiException(
        'Network connection failed. Please check your internet connection.'.tr,
      );
    }

    if (response.statusCode != successStatusCode) {
      _debugService.d(
        'HTTP Status Code Error: ${response.statusCode}',
        args: response.data,
      );
      throw ApiException(
        'Server response error, status code: ${response.statusCode}'.tr,
      );
    }
    return response.data;
  }

  /// 处理通用 API 响应，并返回其中的 'data' 部分解析后的单个对象。
  ///
  /// [apiRequest]: 一个返回 Future<HttpResponse> 的函数，用于执行实际的网络请求。
  /// [itemBuilder]: 一个函数，用于将 Map<String, dynamic> 解析为类型 T 的实例。
  ///
  /// 示例：
  /// ```dart
  /// Future<User> user = ApiResponseHandler.fetchData<User>(
  ///   () => getIHttpService().get('/api/user/profile'), // 你的 HTTP 请求
  ///   (json) => User.fromJson(json), // 将 JSON Map 转换为 User 对象
  /// );
  /// ```
  static Future<T> fetchData<T>(
    Future<HttpResponse> Function() apiRequest,
    T Function(Map<String, dynamic>) itemBuilder,
  ) async {
    dynamic httpData;
    ApiResponse apiResponse;

    try {
      // 1. 获取安全的 HTTP 响应数据
      httpData = await getHttpResponseData(apiRequest);
      // 2. 将 HTTP 响应数据解析为 ApiResponse
      apiResponse = ApiResponse.fromJson(httpData);
    } catch (e) {
      _debugService.d(
        'Failed to parse ApiResponse from HTTP data.',
        args: {'httpData': httpData, 'error': e},
      );
      _debugService.exception(e, StackTrace.current);
      // 如果是 ApiException（如网络错误），直接抛出
      if (e is ApiException) rethrow;
      throw ApiException(
        'Server response format error. Please contact support.'.tr,
      );
    }

    // 3. 检查 API 业务逻辑是否成功
    if (!apiResponse.isSuccess()) {
      _debugService.d('API Business Logic Failed', args: apiResponse.message);
      throw ApiException(apiResponse.message); // 抛出业务错误信息
    }

    // 4. 解析实际的数据部分到 T 类型
    try {
      // 确保 apiResponse.data 是 Map<String, dynamic> 类型，否则可能抛出异常
      if (apiResponse.data is! Map<String, dynamic>) {
        _debugService.d(
          'API data is not a Map<String, dynamic>',
          args: apiResponse.data,
        );
        throw ApiException('Invalid data format received from server.'.tr);
      }
      return itemBuilder(apiResponse.data as Map<String, dynamic>);
    } catch (error, stackTrace) {
      _debugService.exception(error, stackTrace);
      _debugService.d(
        'Failed to convert API data to type $T.',
        args: {'apiData': apiResponse.data, 'error': error},
      );
      throw ApiException(
        'Data parsing failed. Please check the model definition or server response.'
            .tr,
      );
    }
  }

  /// 处理通用 API 列表响应，并返回其中的 'data' 部分解析后的分页对象。
  ///
  /// [apiRequest]: 一个返回 Future<HttpResponse> 的函数，用于执行实际的网络请求。
  /// [itemBuilder]: 一个函数，用于将 List<Map<String, dynamic>> 解析为 List<T>。
  ///
  /// 示例：
  /// ```dart
  /// Future<PaginatedResponse<Product>> products = ApiResponseHandler.fetchPaginatedData<Product>(
  ///   () => getIHttpService().get('/api/products/list'), // 你的 HTTP 请求
  ///   (jsonList) => jsonList.map((e) => Product.fromJson(e)).toList(), // 将 JSON List 转换为 Product List
  /// );
  /// ```
  static Future<PaginatedResponse<T>> fetchPaginatedData<T>(
    Future<HttpResponse> Function() apiRequest,
    List<T> Function(List<Map<String, dynamic>>)? itemBuilder,
  ) async {
    dynamic httpData;
    ApiResponse apiResponse;

    try {
      // 1. 获取安全的 HTTP 响应数据
      httpData = await getHttpResponseData(apiRequest);
      // 2. 将 HTTP 响应数据解析为 ApiResponse
      apiResponse = ApiResponse.fromJson(httpData);
    } catch (e) {
      _debugService.exception(e, StackTrace.current);
      _debugService.d(
        'Failed to parse ApiResponse from HTTP data for paginated response.',
        args: {'httpData': httpData, 'error': e},
      );
      if (e is ApiException) rethrow;
      throw ApiException(
        'Server response format error. Please contact support.'.tr,
      );
    }

    // 3. 检查 API 业务逻辑是否成功
    if (!apiResponse.isSuccess()) {
      _debugService.d(
        'API Business Logic Failed for paginated response',
        args: apiResponse.message,
      );
      throw ApiException(apiResponse.message);
    }

    // 4. 解析实际的列表数据部分到 PaginatedResponse<T> 类型
    try {
      // 确保 apiResponse.data 是 Map<String, dynamic> 类型，因为 PaginatedResponse.fromJson 接收 Map
      if (apiResponse.data is! Map<String, dynamic>) {
        _debugService.d(
          'API data for paginated response is not a Map<String, dynamic>',
          args: apiResponse.data,
        );
        throw ApiException(
          'Invalid paginated data format received from server.'.tr,
        );
      }
      return PaginatedResponse.fromJson(
        apiResponse.data as Map<String, dynamic>,
        itemBuilder,
      );
    } catch (error, stackTrace) {
      _debugService.exception(error, stackTrace);
      _debugService.d(
        'Failed to convert API paginated data to type PaginatedResponse<$T>.',
        args: {'apiData': apiResponse.data, 'error': error},
      );
      throw ApiException(
        'Paginated data parsing failed. Please check the model definition or server response.'
            .tr,
      );
    }
  }
}
