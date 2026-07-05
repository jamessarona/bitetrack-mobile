import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:bitetrack/core/error/failures.dart';
import 'package:bitetrack/core/network/dio_client.dart';
import 'package:bitetrack/features/business/data/models/business_model.dart';

@lazySingleton
class BusinessRemoteDataSource {
  BusinessRemoteDataSource(this._client);

  final DioClient _client;

  Future<List<CategoryModel>> listCategories() async {
    return _wrap(() async {
      final response = await _client.dio.get<Map<String, dynamic>>('/categories');
      final data = response.data!['data'] as List<dynamic>;
      return data
          .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
          .toList();
    });
  }

  Future<List<BusinessModel>> listMyBusinesses() async {
    return _wrap(() async {
      final response = await _client.dio.get<Map<String, dynamic>>('/me/businesses');
      final data = response.data!['data'] as List<dynamic>;
      return data
          .map((item) => BusinessModel.fromJson(item as Map<String, dynamic>))
          .toList();
    });
  }

  Future<BusinessModel> createBusiness({
    required String businessName,
    String? description,
    String? categoryId,
    String? logoUrl,
    String? bannerUrl,
  }) async {
    return _wrap(() async {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/me/businesses',
        data: {
          'businessName': businessName,
          'description': ?description,
          'categoryId': ?categoryId,
          'logoUrl': ?logoUrl,
          'bannerUrl': ?bannerUrl,
        },
      );
      final data = response.data!['data'] as Map<String, dynamic>;
      return BusinessModel.fromJson(data);
    });
  }

  Future<BusinessModel> updateBusiness({
    required String businessId,
    String? businessName,
    String? description,
    String? categoryId,
    String? logoUrl,
    String? bannerUrl,
  }) async {
    return _wrap(() async {
      final response = await _client.dio.patch<Map<String, dynamic>>(
        '/me/businesses/$businessId',
        data: {
          'businessName': ?businessName,
          'description': ?description,
          'categoryId': ?categoryId,
          'logoUrl': ?logoUrl,
          'bannerUrl': ?bannerUrl,
        },
      );
      final data = response.data!['data'] as Map<String, dynamic>;
      return BusinessModel.fromJson(data);
    });
  }

  Future<List<ProductModel>> listProducts(String businessId) async {
    return _wrap(() async {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/me/businesses/$businessId/products',
      );
      final data = response.data!['data'] as List<dynamic>;
      return data
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();
    });
  }

  Future<ProductModel> createProduct({
    required String businessId,
    required String name,
    String? description,
    int? priceCents,
    String? imageUrl,
    bool? isAvailable,
  }) async {
    return _wrap(() async {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/me/businesses/$businessId/products',
        data: {
          'name': name,
          'description': ?description,
          'priceCents': ?priceCents,
          'imageUrl': ?imageUrl,
          'isAvailable': ?isAvailable,
        },
      );
      final data = response.data!['data'] as Map<String, dynamic>;
      return ProductModel.fromJson(data);
    });
  }

  Future<ProductModel> updateProduct({
    required String productId,
    String? name,
    String? description,
    int? priceCents,
    String? imageUrl,
    bool? isAvailable,
  }) async {
    return _wrap(() async {
      final response = await _client.dio.patch<Map<String, dynamic>>(
        '/me/products/$productId',
        data: {
          'name': ?name,
          'description': ?description,
          'priceCents': ?priceCents,
          'imageUrl': ?imageUrl,
          'isAvailable': ?isAvailable,
        },
      );
      final data = response.data!['data'] as Map<String, dynamic>;
      return ProductModel.fromJson(data);
    });
  }

  Future<UploadSessionModel> createUploadSession({
    required String purpose,
    required String contentType,
    String? businessId,
    String? productId,
  }) async {
    return _wrap(() async {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/media/upload-sessions',
        data: {
          'purpose': purpose,
          'contentType': contentType,
          'businessId': ?businessId,
          'productId': ?productId,
        },
      );
      final data = response.data!['data'] as Map<String, dynamic>;
      return UploadSessionModel.fromJson(data);
    });
  }

  Future<void> uploadBytes({
    required String uploadUrl,
    required Uint8List bytes,
    required String contentType,
    Map<String, String>? headers,
  }) async {
    return _wrap(() async {
      final dio = Dio();
      await dio.put<void>(
        uploadUrl,
        data: bytes,
        options: Options(
          headers: {
            'Content-Type': contentType,
            ...?headers,
          },
          validateStatus: (status) => status != null && status >= 200 && status < 300,
        ),
      );
    });
  }

  Future<T> _wrap<T>(Future<T> Function() action) async {
    try {
      return await action();
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
