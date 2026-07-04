import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:bitetrack/core/error/failures.dart';
import 'package:bitetrack/core/network/dio_client.dart';
import 'package:bitetrack/core/theme/theme_preference.dart';
import 'package:bitetrack/features/auth/data/models/user_model.dart';

@lazySingleton
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final DioClient _client;

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return AuthResponseModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<AuthResponseModel> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'firstName': ?firstName,
          'lastName': ?lastName,
        },
      );
      return AuthResponseModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<AuthResponseModel> googleSignIn({required String idToken}) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/auth/google',
        data: {'idToken': idToken},
      );
      return AuthResponseModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<UserModel> me() async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>('/auth/me');
      final data = response.data!['data'] as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<UserModel> updateThemePreference({
    required AppThemePreference themePreference,
  }) async {
    try {
      final response = await _client.dio.patch<Map<String, dynamic>>(
        '/auth/me/preferences',
        data: {'themePreference': themePreference.apiValue},
      );
      final data = response.data!['data'] as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    try {
      final response = await _client.dio.patch<Map<String, dynamic>>(
        '/auth/me/profile',
        data: {
          'firstName': ?firstName,
          'lastName': ?lastName,
          'phone': ?phone,
        },
      );
      final data = response.data!['data'] as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<void> logout({required String refreshToken}) async {
    try {
      await _client.dio.post<void>(
        '/auth/logout',
        data: {'refreshToken': refreshToken},
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Failure _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkFailure();
    }

    final message = _extractMessage(e.response?.data);
    if (e.response?.statusCode == 401) {
      return AuthFailure(message ?? 'Invalid credentials');
    }

    return ServerFailure(message ?? 'Something went wrong');
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        return error['message'] as String?;
      }
    }
    return null;
  }
}
