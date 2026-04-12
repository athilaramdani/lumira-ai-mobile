import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/auth_service.dart';

/// Provider untuk AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// State untuk AuthController
class AuthState {
  final bool isLoading;
  final String? error;
  final String? token;
  final bool isSuccess;

  AuthState({
    this.isLoading = false,
    this.error,
    this.token,
    this.isSuccess = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    String? token,
    bool? isSuccess,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      token: token ?? this.token,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// Controller untuk menangani logic login
class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthController(this._authService) : super(AuthState());

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final token = await _authService.login(email, password);
      
      if (token != null) {
        // Simpan token ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        
        state = state.copyWith(
          isLoading: false, 
          token: token, 
          isSuccess: true
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false, 
          error: 'Login failed. Invalid token received.'
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false, 
        error: e.toString().replaceAll('Exception: ', '')
      );
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    state = AuthState();
  }
}

/// Provider untuk AuthController
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthController(authService);
});
