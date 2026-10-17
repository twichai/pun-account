import 'package:dio/dio.dart';
import '../config/env_config.dart';

class ApiClient {
  ApiClient({String? baseUrl, Dio? dio})
      : _baseUrl = baseUrl ?? EnvConfig.apiBaseUrl {
    _dio = dio ??
        Dio(
          BaseOptions(
            baseUrl: _baseUrl,
            connectTimeout: Duration(milliseconds: EnvConfig.apiTimeoutMs),
            receiveTimeout: Duration(milliseconds: EnvConfig.apiTimeoutMs),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null && _authToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },
      ),
    );
  }

  final String _baseUrl;
  late final Dio _dio;
  String? _authToken;

  String get baseUrl => _baseUrl;
  String? get authToken => _authToken;
  Dio get dio => _dio;

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: headers != null ? Options(headers: headers) : null,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: body,
        queryParameters: queryParameters,
        options: headers != null ? Options(headers: headers) : null,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> put(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: body,
        queryParameters: queryParameters,
        options: headers != null ? Options(headers: headers) : null,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> delete(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: body,
        queryParameters: queryParameters,
        options: headers != null ? Options(headers: headers) : null,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  ApiException _handleDioError(DioException error) {
    final statusCode = error.response?.statusCode ?? 500;
    final responseData = error.response?.data;

    String errorMessage = error.message ?? 'An unexpected network error occurred';

    if (responseData is Map<String, dynamic> && responseData.containsKey('error')) {
      final err = responseData['error'];
      if (err is Map && err.containsKey('message')) {
        errorMessage = err['message'].toString();
      } else if (err is String) {
        errorMessage = err;
      }
    }

    return ApiException(statusCode: statusCode, message: errorMessage);
  }
}

class ApiException implements Exception {
  const ApiException({required this.statusCode, required this.message});

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
