import '../../../domain/entities/user.dart';
import '../../data/models/user_model.dart';

class MockData {
  // Mock User للاختبار
  static UserModel get mockUser => const UserModel(
    id: 'mock_user_123',
    email: 'test@example.com',
    role: UserRole.customer,
    name: 'مستخدم تجريبي',
    age: 25,
    gender: Gender.male,
    isEmailVerified: true,
    lastLogin: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  // Mock Admin User للاختبار
  static UserModel get mockAdminUser => const UserModel(
    id: 'mock_admin_123',
    email: 'admin@example.com',
    role: UserRole.admin,
    name: 'مدير تجريبي',
    age: 30,
    gender: Gender.male,
    isEmailVerified: true,
    lastLogin: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  // Mock Auth Response
  static AuthResponseModel get mockAuthResponse => AuthResponseModel(
    token: 'mock_jwt_token_123456789',
    user: mockUser,
  );

  // Mock Admin Auth Response
  static AuthResponseModel get mockAdminAuthResponse => AuthResponseModel(
    token: 'mock_admin_jwt_token_123456789',
    user: mockAdminUser,
  );
}