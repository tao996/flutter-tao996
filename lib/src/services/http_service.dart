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

abstract class IHttpService {
  Future<HttpResponse> get(
    String url, {
    Dio? dio,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  });

  Future<HttpResponse> post(
    String url, {
    Dio? dio,
    Map<String, dynamic>? data,
    CancelToken? cancelToken,
  });

  Future<HttpResponse> head(String url, {Dio? dio});

  Future<bool> download(
    String url,
    String savePath, {
    Dio? dio,
    void Function(int, int)? onReceiveProgress,
    Options? options,
    CancelToken? cancelToken,
  });

  Dio createDio();
}

class DioHttpClient implements IHttpService {
  static late Dio _dio;
  final ILogService _logger = GetIt.instance.get<ILogService>();
  final ISettingsService _settingSer = GetIt.instance.get<ISettingsService>();
  final IDebugService _debugSer = GetIt.instance.get<IDebugService>();

  DioHttpClient() {
    _dio = createDio();
  }

  @override
  Dio createDio() {
    final dio = Dio();
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

  @override
  Future<HttpResponse> get(
    String url, {
    Dio? dio,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    _debugSer.d('dio.get: $url');
    _debugSer.d('dio.get queryParameters: $queryParameters');
    final response = await (dio ?? _dio).get(
      url,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );
    return HttpResponse(data: response.data, statusCode: response.statusCode);
  }

  @override
  Future<HttpResponse> post(
    String url, {
    Dio? dio,
    Map<String, dynamic>? data,
    CancelToken? cancelToken,
  }) async {
    _debugSer.d('dio.post: $url',args: data);
    final response = await (dio ?? _dio).post(
      url,
      data: data == null ? null : FormData.fromMap(data),
      cancelToken: cancelToken,
    );
    return HttpResponse(data: response.data, statusCode: response.statusCode);
  }

  @override
  Future<HttpResponse> head(String url, {Dio? dio}) async {
    _debugSer.d('dio.header: $url');
    final response = await (dio ?? _dio).head(url);
    return HttpResponse(data: response.data, statusCode: response.statusCode);
  }

  @override
  Future<bool> download(
    String url,
    String savePath, {
    Dio? dio,
    void Function(int, int)? onReceiveProgress,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final Response response = await (dio ?? _dio).download(
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
    _debugService.d('拦截器：错误处理(网络连接错误或网络异常) ${err.message}');
    // throw NoNetworkException('网络连接错误或无网络异常');
    // if (err.type == DioExceptionType.connectionError ||
    //     err.type == DioExceptionType.unknown &&
    //         err.error is NoNetworkException) {
    //   // _messageService.showToast(msg: 'Network Error, please try again.');
    // }
    super.onError(err, handler);
  }
}
