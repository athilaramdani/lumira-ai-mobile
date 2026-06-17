import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  late final Dio _dio;

  factory CloudinaryService() {
    return _instance;
  }

  CloudinaryService._internal() {
    _dio = Dio();
  }

  String get _cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  String get _apiKey => dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  String get _apiSecret => dotenv.env['CLOUDINARY_API_SECRET'] ?? '';

  /// Uploads an image to Cloudinary and returns the secure URL.
  ///
  /// Works on all platforms (Web, Android, iOS) since it takes raw bytes.
  Future<String?> uploadImage(Uint8List imageBytes, String filename) async {
    if (_cloudName.isEmpty || _apiKey.isEmpty || _apiSecret.isEmpty) {
      debugPrint('[CloudinaryService] Error: Missing credentials in .env');
      return null;
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Create signature: sorted parameters + api_secret
    final params = 'timestamp=$timestamp$_apiSecret';
    final signature = sha1.convert(utf8.encode(params)).toString();

    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(imageBytes, filename: filename),
        'api_key': _apiKey,
        'timestamp': timestamp,
        'signature': signature,
      });

      final response = await _dio.post(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final secureUrl = response.data['secure_url'] as String?;
        debugPrint('[CloudinaryService] ✅ Upload success: $secureUrl');
        return secureUrl;
      }

      debugPrint('[CloudinaryService] Upload failed: ${response.data}');
      return null;
    } catch (e) {
      debugPrint('[CloudinaryService] Exception during upload: $e');
      return null;
    }
  }
}
