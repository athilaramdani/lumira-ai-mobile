import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/user_model.dart';

abstract class UsersRemoteDataSource {
  Future<List<UserModel>> getUsers();
  Future<UserModel> getUserById(String id);
  Future<UserModel> createUser(Map<String, dynamic> data);
  Future<UserModel> updateUser(String id, Map<String, dynamic> data);
  Future<void> deleteUser(String id);
}

class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  final Dio _dio = ApiClient().dio;

  @override
  Future<List<UserModel>> getUsers() async {
    final response = await _dio.get(ApiConstants.users);
    final data = response.data['data'] as List;
    return data.map((json) => UserModel.fromJson(json)).toList();
  }

  @override
  Future<UserModel> getUserById(String id) async {
    final response = await _dio.get(ApiConstants.user(id));
    final data = response.data['data'] ?? response.data;
    return UserModel.fromJson(data);
  }

  @override
  Future<UserModel> createUser(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConstants.users, data: data);
    final json = response.data['data'] ?? response.data;
    return UserModel.fromJson(json);
  }

  @override
  Future<UserModel> updateUser(String id, Map<String, dynamic> data) async {
    final response = await _dio.patch(ApiConstants.user(id), data: data);
    final json = response.data['data'] ?? response.data;
    return UserModel.fromJson(json);
  }

  @override
  Future<void> deleteUser(String id) async {
    await _dio.delete(ApiConstants.user(id));
  }
}
