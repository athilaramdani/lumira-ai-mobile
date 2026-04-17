import '../../domain/repositories/users_repository.dart';
import '../datasources/users_remote_data_source.dart';
import '../models/user_model.dart';
import 'package:dio/dio.dart';

class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDataSource remoteDataSource;

  UsersRepositoryImpl({required this.remoteDataSource});

  Never _handleError(Object error) {
    if (error is DioException) {
      throw Exception(error.response?.data?['message'] ?? error.message);
    }
    throw Exception(error.toString());
  }

  @override
  Future<List<UserModel>> getUsers() async {
    try {
      return await remoteDataSource.getUsers();
    } catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<UserModel> getUserById(String id) async {
    try {
      return await remoteDataSource.getUserById(id);
    } catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<UserModel> createUser(Map<String, dynamic> data) async {
    try {
      return await remoteDataSource.createUser(data);
    } catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<UserModel> updateUser(String id, Map<String, dynamic> data) async {
    try {
      return await remoteDataSource.updateUser(id, data);
    } catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      await remoteDataSource.deleteUser(id);
    } catch (e) {
      _handleError(e);
    }
  }
}
