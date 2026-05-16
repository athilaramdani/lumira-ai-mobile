import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/auth_service.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/network/api_client.dart';

/// Provider untuk AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthService(); // Ideally AuthRepositoryImpl
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) => LoginUseCase(ref.watch(authRepositoryProvider)));
final getMeUseCaseProvider = Provider<GetMeUseCase>((ref) => GetMeUseCase(ref.watch(authRepositoryProvider)));
final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) => LogoutUseCase(ref.watch(authRepositoryProvider)));
final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) => UpdateProfileUseCase(ref.watch(authRepositoryProvider)));

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
  final UpdateProfileUseCase _updateProfileUseCase;

  AuthController({
    required LoginUseCase loginUseCase,
    required GetMeUseCase getMeUseCase,
    required LogoutUseCase logoutUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
  })  : _loginUseCase = loginUseCase,
        _getMeUseCase = getMeUseCase,
        _logoutUseCase = logoutUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        super(AuthState()) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      state = state.copyWith(token: token);
      fetchMe().then((_) async {
        // Register token on fresh app start if already logged in AND notifications are enabled
        final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        if (notificationsEnabled) {
          await FirebaseService.registerDeviceToken(ApiClient().dio);
        }
      });
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

        // Register FCM Token for push notifications if enabled
        final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        if (notificationsEnabled) {
          await FirebaseService.registerDeviceToken(ApiClient().dio);
        }

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

        // Persist user info so other parts (e.g. ChatController) can access it
        final prefs = await SharedPreferences.getInstance();
        if (user.id != null) await prefs.setString('user_id', user.id!);
        if (user.role != null) await prefs.setString('user_role', user.role!);
        if (user.name != null) await prefs.setString('user_name', user.name!);
      }
    } catch (e) {
      print('Failed to fetch user data: $e');
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      // Remove FCM Token before logging out from backend
      await FirebaseService.removeDeviceToken(ApiClient().dio);
      await _logoutUseCase();
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('refresh_token');
      state = AuthState(); 
    }
  }

  void updateProfileLocally(UserModel updatedUser) {
    state = state.copyWith(user: updatedUser);
  }

  Future<bool> updateProfile(UserModel updatedUser) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updated = await _updateProfileUseCase(updatedUser);
      if (updated != null) {
        state = state.copyWith(isLoading: false, user: updated);
        
        // Persist local user info update
        final prefs = await SharedPreferences.getInstance();
        if (updated.name != null) await prefs.setString('user_name', updated.name!);
        
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to update profile');
        return false;
      }
    } catch (e) {
      final errMsg = e.toString().replaceAll('Exception: ', '');
      // If token expired or no permission, force logout so user re-authenticates
      if (errMsg.contains('jwt expired') ||
          errMsg.contains('Unauthorized') ||
          errMsg.contains('Insufficient permissions') ||
          errMsg.contains('No auth token')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        await prefs.remove('refresh_token');
        state = AuthState(error: 'Sesi telah berakhir. Silakan login kembali.');
        return false;
      }
      state = state.copyWith(isLoading: false, error: errMsg);
      return false;
    }
  }
}

/// Provider untuk AuthController
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    loginUseCase: ref.watch(loginUseCaseProvider),
    getMeUseCase: ref.watch(getMeUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    updateProfileUseCase: ref.watch(updateProfileUseCaseProvider),
  );
});
