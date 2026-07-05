import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:bitetrack/core/error/failures.dart';
import 'package:bitetrack/features/business/data/datasources/business_remote_datasource.dart';
import 'package:bitetrack/features/business/domain/entities/business.dart';

@lazySingleton
class BusinessRepository {
  BusinessRepository(this._remote);

  final BusinessRemoteDataSource _remote;

  Future<List<Category>> listCategories() async {
    try {
      final models = await _remote.listCategories();
      return models.map((model) => model.toEntity()).toList();
    } on Failure {
      rethrow;
    }
  }

  Future<List<Business>> listNearbyBusinesses({
    required double latitude,
    required double longitude,
    int? radiusMeters,
  }) async {
    try {
      final models = await _remote.listNearbyBusinesses(
        latitude: latitude,
        longitude: longitude,
        radiusMeters: radiusMeters,
      );
      return models.map((model) => model.toEntity()).toList();
    } on Failure {
      rethrow;
    }
  }

  Future<List<Business>> listMyBusinesses() async {
    try {
      final models = await _remote.listMyBusinesses();
      return models.map((model) => model.toEntity()).toList();
    } on Failure {
      rethrow;
    }
  }

  Future<Business> createBusiness({
    required String businessName,
    String? description,
    String? categoryId,
    String? logoUrl,
    String? bannerUrl,
  }) async {
    try {
      final model = await _remote.createBusiness(
        businessName: businessName,
        description: description,
        categoryId: categoryId,
        logoUrl: logoUrl,
        bannerUrl: bannerUrl,
      );
      return model.toEntity();
    } on Failure {
      rethrow;
    }
  }

  Future<Business> updateBusiness({
    required String businessId,
    String? businessName,
    String? description,
    String? categoryId,
    String? logoUrl,
    String? bannerUrl,
  }) async {
    try {
      final model = await _remote.updateBusiness(
        businessId: businessId,
        businessName: businessName,
        description: description,
        categoryId: categoryId,
        logoUrl: logoUrl,
        bannerUrl: bannerUrl,
      );
      return model.toEntity();
    } on Failure {
      rethrow;
    }
  }

  Future<List<Product>> listProducts(String businessId) async {
    try {
      final models = await _remote.listProducts(businessId);
      return models.map((model) => model.toEntity()).toList();
    } on Failure {
      rethrow;
    }
  }

  Future<Business> startSelling({
    required String businessId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final model = await _remote.startSelling(
        businessId: businessId,
        latitude: latitude,
        longitude: longitude,
      );
      return model.toEntity();
    } on Failure {
      rethrow;
    }
  }

  Future<Business> stopSelling({required String businessId}) async {
    try {
      final model = await _remote.stopSelling(businessId: businessId);
      return model.toEntity();
    } on Failure {
      rethrow;
    }
  }

  Future<Business> updateSellingLocation({
    required String businessId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final model = await _remote.updateSellingLocation(
        businessId: businessId,
        latitude: latitude,
        longitude: longitude,
      );
      return model.toEntity();
    } on Failure {
      rethrow;
    }
  }

  Future<Product> createProduct({
    required String businessId,
    required String name,
    String? description,
    int? priceCents,
    String? imageUrl,
    bool? isAvailable,
  }) async {
    try {
      final model = await _remote.createProduct(
        businessId: businessId,
        name: name,
        description: description,
        priceCents: priceCents,
        imageUrl: imageUrl,
        isAvailable: isAvailable,
      );
      return model.toEntity();
    } on Failure {
      rethrow;
    }
  }

  Future<Product> updateProduct({
    required String productId,
    String? name,
    String? description,
    int? priceCents,
    String? imageUrl,
    bool? isAvailable,
  }) async {
    try {
      final model = await _remote.updateProduct(
        productId: productId,
        name: name,
        description: description,
        priceCents: priceCents,
        imageUrl: imageUrl,
        isAvailable: isAvailable,
      );
      return model.toEntity();
    } on Failure {
      rethrow;
    }
  }

  Future<String> uploadImage({
    required String purpose,
    required Uint8List bytes,
    required String contentType,
    String? businessId,
    String? productId,
  }) async {
    try {
      final session = await _remote.createUploadSession(
        purpose: purpose,
        contentType: contentType,
        businessId: businessId,
        productId: productId,
      );
      await _remote.uploadBytes(
        uploadUrl: session.uploadUrl,
        bytes: bytes,
        contentType: contentType,
        headers: session.headers,
      );
      return session.publicUrl;
    } on Failure {
      rethrow;
    }
  }
}
