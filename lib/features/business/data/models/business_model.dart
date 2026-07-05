import 'package:bitetrack/features/business/domain/entities/business.dart';

class BusinessModel {
  BusinessModel({
    required this.id,
    required this.slug,
    required this.businessName,
    this.description,
    this.logoUrl,
    this.bannerUrl,
    required this.verificationStatus,
    required this.status,
    required this.averageRating,
    required this.reviewCount,
    this.categoryId,
    this.latitude,
    this.longitude,
    this.distanceMeters,
    this.isLive = false,
    this.activeShiftId,
    this.lastSeenAt,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'] as String,
      slug: json['slug'] as String,
      businessName: json['businessName'] as String,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      bannerUrl: json['bannerUrl'] as String?,
      verificationStatus: json['verificationStatus'] as String,
      status: json['status'] as String,
      averageRating: (json['averageRating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      categoryId: json['categoryId'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble(),
      isLive: json['isLive'] as bool? ?? false,
      activeShiftId: json['activeShiftId'] as String?,
      lastSeenAt: json['lastSeenAt'] != null
          ? DateTime.tryParse(json['lastSeenAt'] as String)
          : null,
    );
  }

  final String id;
  final String slug;
  final String businessName;
  final String? description;
  final String? logoUrl;
  final String? bannerUrl;
  final String verificationStatus;
  final String status;
  final double averageRating;
  final int reviewCount;
  final String? categoryId;
  final double? latitude;
  final double? longitude;
  final double? distanceMeters;
  final bool isLive;
  final String? activeShiftId;
  final DateTime? lastSeenAt;

  Business toEntity() {
    return Business(
      id: id,
      slug: slug,
      businessName: businessName,
      description: description,
      logoUrl: logoUrl,
      bannerUrl: bannerUrl,
      verificationStatus: _mapVerificationStatus(verificationStatus),
      status: _mapStatus(status),
      averageRating: averageRating,
      reviewCount: reviewCount,
      categoryId: categoryId,
      latitude: latitude,
      longitude: longitude,
      distanceMeters: distanceMeters,
      isLive: isLive,
      activeShiftId: activeShiftId,
      lastSeenAt: lastSeenAt,
    );
  }

  static BusinessVerificationStatus _mapVerificationStatus(String value) {
    return switch (value) {
      'VERIFIED' => BusinessVerificationStatus.verified,
      'REJECTED' => BusinessVerificationStatus.rejected,
      _ => BusinessVerificationStatus.pending,
    };
  }

  static BusinessStatus _mapStatus(String value) {
    return switch (value) {
      'ONLINE' => BusinessStatus.online,
      'ON_ROUTE' => BusinessStatus.onRoute,
      'AVAILABLE' => BusinessStatus.available,
      'BUSY' => BusinessStatus.busy,
      _ => BusinessStatus.offline,
    };
  }
}

class ProductModel {
  ProductModel({
    required this.id,
    required this.businessId,
    required this.name,
    this.description,
    required this.priceCents,
    required this.currency,
    this.imageUrl,
    required this.isAvailable,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      businessId: json['businessId'] as String? ?? '',
      name: json['name'] as String,
      description: json['description'] as String?,
      priceCents: json['priceCents'] as int,
      currency: json['currency'] as String? ?? 'PHP',
      imageUrl: json['imageUrl'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  final String id;
  final String businessId;
  final String name;
  final String? description;
  final int priceCents;
  final String currency;
  final String? imageUrl;
  final bool isAvailable;

  Product toEntity() {
    return Product(
      id: id,
      businessId: businessId,
      name: name,
      description: description,
      priceCents: priceCents,
      currency: currency,
      imageUrl: imageUrl,
      isAvailable: isAvailable,
    );
  }
}

class CategoryModel {
  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.iconUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      iconUrl: json['iconUrl'] as String?,
    );
  }

  final String id;
  final String name;
  final String slug;
  final String? iconUrl;

  Category toEntity() {
    return Category(id: id, name: name, slug: slug, iconUrl: iconUrl);
  }
}

class UploadSessionModel {
  UploadSessionModel({
    required this.objectKey,
    required this.uploadUrl,
    required this.publicUrl,
    required this.expiresAt,
    this.headers,
  });

  factory UploadSessionModel.fromJson(Map<String, dynamic> json) {
    final rawHeaders = json['headers'];
    Map<String, String>? headers;
    if (rawHeaders is Map) {
      headers = rawHeaders.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }

    return UploadSessionModel(
      objectKey: json['objectKey'] as String,
      uploadUrl: json['uploadUrl'] as String,
      publicUrl: json['publicUrl'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      headers: headers,
    );
  }

  final String objectKey;
  final String uploadUrl;
  final String publicUrl;
  final DateTime expiresAt;
  final Map<String, String>? headers;

  UploadSession toEntity() {
    return UploadSession(
      objectKey: objectKey,
      uploadUrl: uploadUrl,
      publicUrl: publicUrl,
      expiresAt: expiresAt,
      headers: headers,
    );
  }
}
