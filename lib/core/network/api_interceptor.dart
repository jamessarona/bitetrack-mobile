import 'package:dio/dio.dart';
import 'package:bitetrack/core/storage/token_storage.dart';

/// Attaches the JWT access token to outgoing requests.
class ApiInterceptor extends Interceptor {
  ApiInterceptor(this._tokenStorage);

  final TokenStorage _tokenStorage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokenStorage.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
