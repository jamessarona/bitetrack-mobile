import 'package:flutter_test/flutter_test.dart';
import 'package:bitetrack/features/auth/data/models/user_model.dart';
import 'package:bitetrack/features/auth/domain/entities/user.dart';

void main() {
  group('UserModel', () {
    test('fromJson maps user fields', () {
      final model = UserModel.fromJson({
        'id': '11111111-1111-1111-1111-111111111111',
        'email': 'user@test.com',
        'role': 'VENDOR',
        'status': 'ACTIVE',
        'firstName': 'Test',
        'lastName': 'User',
      });

      expect(model.email, 'user@test.com');
      expect(model.role, 'VENDOR');
    });

    test('toEntity maps vendor role', () {
      const model = UserModel(
        id: '11111111-1111-1111-1111-111111111111',
        email: 'vendor@test.com',
        role: 'VENDOR',
        status: 'ACTIVE',
        firstName: 'Mang',
      );

      final entity = model.toEntity();

      expect(entity.role, UserRole.vendor);
      expect(entity.displayName, 'Mang');
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
          },
          'accessToken': 'access-token',
          'refreshToken': 'refresh-token',
        },
      });

      expect(model.accessToken, 'access-token');
      expect(model.user.email, 'user@test.com');
    });
  });
}
