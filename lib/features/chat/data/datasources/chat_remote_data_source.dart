import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/chat_message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatMessageModel>> getChatHistory(String patientId);
  Future<ChatMessageModel> sendMessage(String patientId, String message);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio _dio = ApiClient().dio;

  @override
  Future<List<ChatMessageModel>> getChatHistory(String patientId) async {
    final response = await _dio.get(ApiConstants.chat(patientId));
    final data = response.data['data'] as List?;
    if (data == null) return [];
    return data.map((json) => ChatMessageModel.fromJson(json)).toList();
  }

  @override
  Future<ChatMessageModel> sendMessage(String patientId, String message) async {
    final response = await _dio.post(
      ApiConstants.chat(patientId),
      data: {'message': message},
    );
    return ChatMessageModel.fromJson(response.data['data']);
  }
}
