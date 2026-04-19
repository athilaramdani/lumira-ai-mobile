import '../../data/models/user_model.dart';

abstract class UsersRepository {
  Future<List<UserModel>> getUsers();
  Future<UserModel> getUserById(String id);
  Future<UserModel> createUser(Map<String, dynamic> data);
  Future<UserModel> updateUser(String id, Map<String, dynamic> data);
  Future<void> deleteUser(String id);
}
