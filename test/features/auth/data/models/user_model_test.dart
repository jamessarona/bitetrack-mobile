import 'package:flutter_test/flutter_test.dart';
import 'package:bitetrack/core/theme/theme_preference.dart';
import 'package:bitetrack/features/auth/data/models/user_model.dart';
import 'package:bitetrack/features/auth/domain/entities/user.dart';

void main() {
  group('UserModel', () {
    test('fromJson maps user fields including businessCount', () {
      final model = UserModel.fromJson({
        'id': '11111111-1111-1111-1111-111111111111',
        'email': 'user@test.com',
        'role': 'CUSTOMER',
        'status': 'ACTIVE',
        'firstName': 'Test',
        'lastName': 'User',
        'businessCount': 2,
      });

      expect(model.email, 'user@test.com');
      expect(model.role, 'CUSTOMER');
      expect(model.businessCount, 2);
    });

    test('toEntity treats legacy vendor role as customer', () {
      const model = UserModel(
        id: '11111111-1111-1111-1111-111111111111',
        email: 'seller@test.com',
        role: 'VENDOR',
        status: 'ACTIVE',
        firstName: 'Mang',
        lastName: 'Seller',
        businessCount: 1,
      );

      final entity = model.toEntity();

      expect(entity.role, UserRole.customer);
      expect(entity.hasBusinesses, isTrue);
      expect(entity.displayName, 'Mang Seller');
    });

    test('fromJson maps theme preference', () {
      final model = UserModel.fromJson({
        'id': '11111111-1111-1111-1111-111111111111',
        'email': 'user@test.com',
        'role': 'CUSTOMER',
        'status': 'ACTIVE',
        'firstName': 'Test',
        'lastName': 'User',
        'themePreference': 'DARK',
      });

      expect(model.themePreference, 'DARK');
      expect(model.toEntity().themePreference, AppThemePreference.dark);
    });
  });

  group('AuthResponseModel', () {
    test('fromJson parses wrapped API response', () {
      final model = AuthResponseModel.fromJson({
        'success': true,
        'data': {
          'user': {
            'id': '11111111-1111-1111-1111-111111111111',
            'email': 'user@test.com',
            'role': 'CUSTOMER',
            'status': 'ACTIVE',
            'firstName': 'Test',
            'lastName': 'User',
            'businessCount': 0,
          },
          'accessToken': 'access-token',
          'refreshToken': 'refresh-token',
        },
      });

      expect(model.accessToken, 'access-token');
      expect(model.user.email, 'user@test.com');
      expect(model.user.businessCount, 0);
    });
  });
}
