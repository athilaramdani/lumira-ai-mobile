import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<Map<String, String>?> login(String email, String password);
  Future<UserModel?> getMe();
  Future<void> logout();
}
