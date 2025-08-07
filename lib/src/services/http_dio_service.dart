import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:get_it/get_it.dart';

import 'debug_service.dart';
import 'network_service.dart';
import 'setting_service.dart';
import 'log_service.dart';

class HttpResponse {
  final dynamic data;
  final int? statusCode;

  HttpResponse({required this.data, this.statusCode});
}

abstract class IDioHttpService{
  Future<HttpResponse> get(
    String url, {
    Dio? dio,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Object? data,
    Options? options,
    void Function(int, int)? onReceiveProgress,
  });

  Future<HttpResponse> post(
    String url, {
    Dio? dio,
    Map<String, dynamic>? data,
    CancelToken? cancelToken,
    Map<String, dynamic>? queryParameters,
    Options? options,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  });

  Future<HttpResponse> head(
    String url, {
    Dio? dio,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<bool> download(
    String url,
    String savePath, {
    Dio? dio,
    void Function(int, int)? onReceiveProgress,
    Options? options,
    CancelToken? cancelToken,
  });
}

class DioHttpService implements IDioHttpService {
  static late Dio _dio;
  final ILogService _logger = GetIt.instance.get<ILogService>();
  final ISettingsService _settingSer = GetIt.instance.get<ISettingsService>();
  final IDebugService _debugSer = GetIt.instance.get<IDebugService>();

  DioHttpService({BaseOptions? options}) {
    _dio = createDio(options: options);
  }

  /*
  final BaseOptions options = BaseOptions(
    baseUrl: 'https://api.example.com',
    // 你的 API 基础 URL
    connectTimeout: const Duration(seconds: 10),
    // 连接超时时间
    receiveTimeout: const Duration(seconds: 15),
    // 接收超时时间

    // 定义请求头
    headers: {
      // User-Agent: 标识客户端类型和版本。
      // 对于 Flutter 应用，可以包含应用名称、版本、操作系统信息。
      'User-Agent': 'YourAppName/1.0.0 (Flutter; Android/iOS)',

      // Accept: 客户端能够处理的响应内容类型。
      // 通常用于指定接受 JSON 数据。
      'Accept': 'application/json',

      // Accept-Encoding: 客户端支持的内容编码方式，用于数据压缩。
      // gzip 和 deflate 是常见的压缩算法。
      'Accept-Encoding': 'gzip, deflate',

      // 还可以添加其他自定义头，例如认证 token
      // 'Authorization': 'Bearer your_token_here',
      // 'X-Custom-Header': 'some_value',
    },
    contentType: Headers.jsonContentType,
    // 设置默认请求体内容类型为 JSON
    responseType: ResponseType.json, // 期望的响应类型为 JSON
  );
*/

  Dio createDio({BaseOptions? options}) {
    final dio = Dio(options);
    String proxyAddress = _settingSer.proxyAddress;
    String proxyPort = _settingSer.proxyPort;
    bool isProxy = _settingSer.useProxy;
    if (isProxy && proxyAddress.isNotEmpty && proxyPort.isNotEmpty) {
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.findProxy = (uri) {
            return 'PROXY $proxyAddress:$proxyPort';
          };
          return client;
        },
      );
      _logger.i('[dio]: Init Dio with proxy: $proxyAddress:$proxyPort.');
    } else {
      _logger.i('[dio]: Init Dio without proxy.');
    }
    dio.interceptors.add(NetworkInterceptor());
    return dio;
  }

  /// 创建一个打印日志的 dio
  ///
  /// [request] 是否打印请求信息, [requestHeader] 是否打印请求头信息, [requestBody] 是否打印请求体（body),
  /// [responseHeader] 是否打印响应头信息,[responseBody] 是否打印响应体信息,
  /// [error] 是否打印错误信息
  /// [all] 全部设置为 true; [allRequest] 将 request 全部设置为 ture; [allResponse] 将 response 全部设置为 true
  Dio createLogDio({
    bool request = false,
    bool requestHeader = false,
    bool requestBody = false,
    bool responseHeader = false,
    bool responseBody = false,
    bool error = true,
    // 快捷设置
    bool all = true,
    bool allRequest = false,
    bool allResponse = false,
  }) {
    final dio = createDio();

    // 只要有一个设置，即关闭 all
    if (allRequest ||
        allResponse ||
        request ||
        requestHeader ||
        requestBody ||
        responseHeader ||
        responseBody) {
      all = false;
    }
    dio.interceptors.add(
      LogInterceptor(
        request: all || allRequest || request,
        requestHeader: all || allRequest || requestHeader,
        requestBody: all || allRequest || requestBody,
        responseHeader: all || allResponse || responseHeader,
        responseBody: all || allResponse || responseBody,
        error: error,
      ),
    );
    return dio;
  }

  Dio _getDio(Dio? dio) {
    return (dio ?? _dio);
  }

  @override
  Future<HttpResponse> get(
    String url, {
    Dio? dio,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Object? data,
    Options? options,
    void Function(int, int)? onReceiveProgress,
  }) async {
    _debugSer.d('dio.get:[$url]');
    final response = await _getDio(dio).get(
      url,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      data: data,
      options: options,
      onReceiveProgress: onReceiveProgress,
    );
    return HttpResponse(data: response.data, statusCode: response.statusCode);
  }

  @override
  Future<HttpResponse> post(
    String url, {
    Dio? dio,
    Map<String, dynamic>? data,
    CancelToken? cancelToken,
    Map<String, dynamic>? queryParameters,
    Options? options,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    _debugSer.d('dio.post:[$url]', args: data);
    final response = await _getDio(dio).post(
      url,
      data: data == null ? null : FormData.fromMap(data),
      cancelToken: cancelToken,
      queryParameters: queryParameters,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
    return HttpResponse(data: response.data, statusCode: response.statusCode);
  }

  @override
  Future<HttpResponse> head(
    String url, {
    Dio? dio,
    bool? log,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    _debugSer.d('dio.header:[$url]');
    final response = await _getDio(dio).head(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
    return HttpResponse(data: response.data, statusCode: response.statusCode);
  }

  @override
  Future<bool> download(
    String url,
    String savePath, {
    Dio? dio,
    bool? log,
    void Function(int, int)? onReceiveProgress,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final Response response = await _getDio(dio).download(
      url,
      savePath,
      onReceiveProgress: onReceiveProgress,
      options: options,
      cancelToken: cancelToken,
    );
    if (response.statusCode == 200) {
      // 尝试从响应头中获取更准确的 MIME 类型
      String? contentType = response.headers.value('Content-Type');
      if (isDebugMode) {
        _debugSer.d('下载图片 Content-Type: $contentType');
      }
      _logger.d('download success: $url => $savePath');
      return true;
    } else {
      _logger.d('download failed: $url');
      return false;
    }
  }
}

// 自定义异常
class NoNetworkException implements Exception {
  final String message;

  NoNetworkException(this.message);

  @override
  String toString() => message;
}

class NetworkInterceptor extends Interceptor {
  final INetworkService _networkService = GetIt.instance.get<INetworkService>();
  final IDebugService _debugService = GetIt.instance.get<IDebugService>();

  // final IMessageService _messageService = GetIt.instance.get<IMessageService>();

  NetworkInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 在请求发送前检查网络状态
    if (_networkService.currentNetworkState.isNoNetwork) {
      // 如果没有网络，直接拒绝请求并抛出自定义异常
      _debugService.d('拦截器：没有网络连接，请求被取消');
      // throw NoNetworkException();
      // _messageService.showToast(msg: 'No Internet Connection');
      return handler.reject(
        DioException(
          requestOptions: options,
          error: NoNetworkException('No Internet Connection'.tr),
          type: DioExceptionType.unknown,
        ),
      );
    }
    // 如果有网络，继续请求
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 处理网络相关的错误
    _debugService.d('拦截器：错误处理(网络连接错误或网络异常)', args: err);
    // throw NoNetworkException('网络连接错误或无网络异常');
    // if (err.type == DioExceptionType.connectionError ||
    //     err.type == DioExceptionType.unknown &&
    //         err.error is NoNetworkException) {
    //   // _messageService.showToast(msg: 'Network Error, please try again.');
    // }
    super.onError(err, handler);
  }
}
