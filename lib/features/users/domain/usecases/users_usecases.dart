import '../repositories/users_repository.dart';
import '../../data/models/user_model.dart';

class GetUsersUseCase {
  final UsersRepository repository;
  GetUsersUseCase(this.repository);

  Future<List<UserModel>> call() async {
    return await repository.getUsers();
  }
}

class GetUserByIdUseCase {
  final UsersRepository repository;
  GetUserByIdUseCase(this.repository);

  Future<UserModel> call(String id) async {
    return await repository.getUserById(id);
  }
}

class CreateUserUseCase {
  final UsersRepository repository;
  CreateUserUseCase(this.repository);

  Future<UserModel> call(Map<String, dynamic> data) async {
    return await repository.createUser(data);
  }
}

class UpdateUserUseCase {
  final UsersRepository repository;
  UpdateUserUseCase(this.repository);

  Future<UserModel> call(String id, Map<String, dynamic> data) async {
    return await repository.updateUser(id, data);
  }
}

class DeleteUserUseCase {
  final UsersRepository repository;
  DeleteUserUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteUser(id);
  }
}
