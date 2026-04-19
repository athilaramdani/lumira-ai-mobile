import '../repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<Map<String, String>?> call(String email, String password) async {
    return await repository.login(email, password);
  }
}

class GetMeUseCase {
  final AuthRepository repository;
  GetMeUseCase(this.repository);

  Future<UserModel?> call() async {
    return await repository.getMe();
  }
}

class LogoutUseCase {
  final AuthRepository repository;
  LogoutUseCase(this.repository);

  Future<void> call() async {
    return await repository.logout();
  }
}
