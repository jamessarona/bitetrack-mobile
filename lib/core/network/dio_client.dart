import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:bitetrack/core/config/env_config.dart';
import 'package:bitetrack/core/network/api_interceptor.dart';
import 'package:bitetrack/core/storage/token_storage.dart';

@lazySingleton
class DioClient {
  DioClient(this._tokenStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.instance.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(ApiInterceptor(_tokenStorage));

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
  }

  final TokenStorage _tokenStorage;
  late final Dio _dio;

  Dio get dio => _dio;
}
