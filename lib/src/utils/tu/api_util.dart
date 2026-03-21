import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

class ApiUtil {
  const ApiUtil();

  /// 获取原始响应内容，需要自己手动再转换
  ///
  /// [apiRequest]: 一个返回 `Future<HttpResponse>` 的函数，用于执行实际的网络请求。
  ///
  /// 示例：
  /// ```dart
  /// final responseData = awiat tu.api.getHttpResponseData<User>(
  ///   () => getIHttpService().get('/api/user/profile'), // 你的 HTTP 请求
  /// );
  /// ```
  Future<dynamic> getHttpResponseData(
    Future<HttpResponse> Function() apiRequest, {
    int successStatusCode = 200,
  }) async {
    HttpResponse response;
    try {
      response = await apiRequest(); // 调用传入的回调函数执行网络请求
    } catch (error, stackTrace) {
      if (kDebugMode) {
        getIDebugService().exception(error, stackTrace);
      }
      throw MyApiException(
        'Network connection failed. Please check your internet connection.'.tr,
      );
    }

    if (response.statusCode != successStatusCode) {
      if (kDebugMode) {
        getIDebugService().d(
          'HTTP Status Code Error: ${response.statusCode}',
          args: response.data,
        );
      }
      throw MyApiException(
        'Server response error, status code: ${response.statusCode}'.tr,
      );
    }
    return response.data;
  }

  /// 对 [getHttpResponseData] 方法进行封装，处理 API 响应并返回数据。
  /// 注意：如果接口返回数据与 [MyApiResponse] 不兼容，则需要定义 [apiResposeHandler] 回调函数，处理返回的 JSON 数据。
  ///
  /// [apiRequest]: 一个返回 `Future<HttpResponse>` 的函数，用于执行实际的网络请求。
  ///
  /// 示例：
  /// ```dart
  /// tu.api.fetchData<User>(
  ///   () => getIHttpService().get('/api/user/profile'), // 你的 HTTP 请求
  /// );
  /// ```
  Future<MyApiResponse> getApiResponse(
    Future<HttpResponse> Function() apiRequest, {
    MyApiResponse Function(dynamic data)? apiResposeHandler,
  }) async {
    dynamic httpData;
    MyApiResponse apiResponse;

    try {
      // 1. 获取安全的 HTTP 响应数据
      httpData = await getHttpResponseData(apiRequest);
      // 2. 将 HTTP 响应数据解析为 ApiResponse
      apiResponse = apiResposeHandler == null
          ? MyApiResponse.fromJson(httpData)
          : apiResposeHandler(httpData);
    } catch (e, st) {
      if (kDebugMode) {
        getIDebugService().d(
          'Failed to parse ApiResponse from HTTP data.',
          args: {'httpData': httpData, 'error': e},
        );
        getIDebugService().exception(e, st);
      }
      // 如果是 ApiException（如网络错误），直接抛出
      if (e is MyApiException) rethrow;
      throw MyApiException(
        'Server response format error. Please contact support.'.tr,
      );
    }

    // 3. 检查 API 业务逻辑是否成功
    if (!apiResponse.isSuccess()) {
      if (kDebugMode) {
        getIDebugService().d(
          'API Business Logic Failed',
          args: apiResponse.message,
        );
      }
      throw MyApiException(apiResponse.message); // 抛出业务错误信息
    }
    return apiResponse;
  }

  // /// 对 [fetchData] 的进一步封装，用于处理分页对象。注意：接口的返回格式必须是 [MyApiResponse]
  // ///
  // /// [apiRequest]: 一个返回 `Future<HttpResponse>` 的函数，用于执行实际的网络请求。
  // /// [itemBuilder]: 一个函数，用于将 `List<Map<String, dynamic>>` 解析为 `List<T>`。
  // ///
  // /// 示例：
  // /// ```dart
  // /// Future<PaginatedResponse<Product>> products = tu.api.fetchPaginatedData<Product>(
  // ///   () => getIHttpService().get('/api/products/list'), // 你的 HTTP 请求
  // ///   (jsonList) => jsonList.map((e) => Product.fromJson(e)).toList(), // 将 JSON List 转换为 Product List
  // /// );
  // /// ```
  // Future<MyPaginatedResponse<T>> fetchPaginatedData<T>(
  //   Future<HttpResponse> Function() apiRequest,
  //   List<T> Function(List<Map<String, dynamic>>)? itemBuilder, {
  //   MyApiResponse Function(dynamic data)? apiResposeHandler,
  // }) async {
  //   dynamic httpData;
  //   MyApiResponse apiResponse;

  //   try {
  //     // 1. 获取安全的 HTTP 响应数据
  //     httpData = await getHttpResponseData(apiRequest);
  //     // 2. 将 HTTP 响应数据解析为 ApiResponse
  //     apiResponse = apiResposeHandler == null
  //         ? MyApiResponse.fromJson(httpData)
  //         : apiResposeHandler(httpData);
  //   } catch (e) {
  //     if (kDebugMode) {
  //       getIDebugService().d(
  //         'Failed to parse ApiResponse from HTTP data for paginated response.',
  //         args: {'httpData': httpData, 'error': e},
  //       );
  //       getIDebugService().exception(e, StackTrace.current);
  //     }
  //     if (e is MyApiException) rethrow;
  //     throw MyApiException(
  //       'Server response format error. Please contact support.'.tr,
  //     );
  //   }

  //   // 3. 检查 API 业务逻辑是否成功
  //   if (!apiResponse.isSuccess()) {
  //     if (kDebugMode) {
  //       getIDebugService().d(
  //         'API Business Logic Failed for paginated response',
  //         args: apiResponse.message,
  //       );
  //     }
  //     throw MyApiException(apiResponse.message);
  //   }

  //   // 4. 解析实际的列表数据部分到 PaginatedResponse<T> 类型
  //   try {
  //     // 确保 apiResponse.data 是 Map<String, dynamic> 类型，因为 PaginatedResponse.fromJson 接收 Map
  //     if (apiResponse.data is! Map<String, dynamic>) {
  //       if (kDebugMode) {
  //         getIDebugService().d(
  //           'API data for paginated response is not a Map<String, dynamic>',
  //           args: apiResponse.data,
  //         );
  //       }
  //       throw MyApiException(
  //         'Invalid paginated data format received from server.'.tr,
  //       );
  //     }
  //     return MyPaginatedResponse.fromJson(
  //       apiResponse.data as Map<String, dynamic>,
  //       itemBuilder,
  //     );
  //   } catch (error, stackTrace) {
  //     if (kDebugMode) {
  //       getIDebugService().exception(error, stackTrace);
  //       getIDebugService().d(
  //         'Failed to convert API paginated data to type PaginatedResponse<$T>.',
  //         args: {'apiData': apiResponse.data, 'error': error},
  //       );
  //     }
  //     throw MyApiException(
  //       'Paginated data parsing failed. Please check the model definition or server response.'
  //           .tr,
  //     );
  //   }
  // }
}
