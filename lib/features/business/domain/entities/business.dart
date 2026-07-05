enum BusinessVerificationStatus { pending, verified, rejected }

enum BusinessStatus { offline, online, onRoute, available, busy }

class Business {
  const Business({
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

  final String id;
  final String slug;
  final String businessName;
  final String? description;
  final String? logoUrl;
  final String? bannerUrl;
  final BusinessVerificationStatus verificationStatus;
  final BusinessStatus status;
  final double averageRating;
  final int reviewCount;
  final String? categoryId;
  final double? latitude;
  final double? longitude;
  final double? distanceMeters;
  final bool isLive;
  final String? activeShiftId;
  final DateTime? lastSeenAt;

  bool get canGoLive => verificationStatus == BusinessVerificationStatus.verified;
}

class Product {
  const Product({
    required this.id,
    required this.businessId,
    required this.name,
    this.description,
    required this.priceCents,
    required this.currency,
    this.imageUrl,
    required this.isAvailable,
  });

  final String id;
  final String businessId;
  final String name;
  final String? description;
  final int priceCents;
  final String currency;
  final String? imageUrl;
  final bool isAvailable;
}

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.iconUrl,
  });

  final String id;
  final String name;
  final String slug;
  final String? iconUrl;
}

class UploadSession {
  const UploadSession({
    required this.objectKey,
    required this.uploadUrl,
    required this.publicUrl,
    required this.expiresAt,
    this.headers,
  });

  final String objectKey;
  final String uploadUrl;
  final String publicUrl;
  final DateTime expiresAt;
  final Map<String, String>? headers;
}
