import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/auth_service.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';

/// Provider untuk AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthService(); // Ideally AuthRepositoryImpl
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) => LoginUseCase(ref.watch(authRepositoryProvider)));
final getMeUseCaseProvider = Provider<GetMeUseCase>((ref) => GetMeUseCase(ref.watch(authRepositoryProvider)));
final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) => LogoutUseCase(ref.watch(authRepositoryProvider)));

/// State untuk AuthController
class AuthState {
  final bool isLoading;
  final String? error;
  final String? token;
  final bool isSuccess;
  final UserModel? user;

  AuthState({
    this.isLoading = false,
    this.error,
    this.token,
    this.isSuccess = false,
    this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    String? token,
    bool? isSuccess,
    UserModel? user,
    bool clearUser = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      token: token ?? this.token,
      isSuccess: isSuccess ?? this.isSuccess,
      user: clearUser ? null : (user ?? this.user),
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final GetMeUseCase _getMeUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthController({
    required LoginUseCase loginUseCase,
    required GetMeUseCase getMeUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _loginUseCase = loginUseCase,
        _getMeUseCase = getMeUseCase,
        _logoutUseCase = logoutUseCase,
        super(AuthState()) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      state = state.copyWith(token: token);
      fetchMe(); // fetch user data if already logged in
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final tokens = await _loginUseCase(email, password);
      
      if (tokens != null && tokens.containsKey('accessToken')) {
        final prefs = await SharedPreferences.getInstance();
        final token = tokens['accessToken']!;
        await prefs.setString('auth_token', token);
        
        if (tokens.containsKey('refreshToken')) {
          await prefs.setString('refresh_token', tokens['refreshToken']!);
        }
        // Fetch user details after login, BEFORE triggering success state
        // This ensures that user role is available for navigation routing
        await fetchMe(); 

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

  Future<void> fetchMe() async {
    try {
      final user = await _getMeUseCase();
      if (user != null) {
        state = state.copyWith(user: user);
      }
    } catch (e) {
      print('Failed to fetch user data: $e');
      // If fetching user fails due to 401, interceptor will try to refresh.
      // If that fails, the interceptor clears tokens.
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _logoutUseCase();
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('refresh_token');
      state = AuthState(); 
    }
  }
}

/// Provider untuk AuthController
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    loginUseCase: ref.watch(loginUseCaseProvider),
    getMeUseCase: ref.watch(getMeUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
  );
});
