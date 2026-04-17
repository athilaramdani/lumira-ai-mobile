import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/users_remote_data_source.dart';
import '../../data/repositories/users_repository_impl.dart';
import '../../domain/repositories/users_repository.dart';
import '../../domain/usecases/users_usecases.dart';
import '../../data/models/user_model.dart';

// Providers
final usersRemoteDataSourceProvider = Provider<UsersRemoteDataSource>((ref) {
  return UsersRemoteDataSourceImpl();
});

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  final dataSource = ref.watch(usersRemoteDataSourceProvider);
  return UsersRepositoryImpl(remoteDataSource: dataSource);
});

final getUsersUseCaseProvider = Provider((ref) => GetUsersUseCase(ref.watch(usersRepositoryProvider)));
final getUserByIdUseCaseProvider = Provider((ref) => GetUserByIdUseCase(ref.watch(usersRepositoryProvider)));
final createUserUseCaseProvider = Provider((ref) => CreateUserUseCase(ref.watch(usersRepositoryProvider)));
final updateUserUseCaseProvider = Provider((ref) => UpdateUserUseCase(ref.watch(usersRepositoryProvider)));
final deleteUserUseCaseProvider = Provider((ref) => DeleteUserUseCase(ref.watch(usersRepositoryProvider)));

// State
class UsersState {
  final bool isLoading;
  final String? error;
  final List<UserModel> users;

  UsersState({
    this.isLoading = false,
    this.error,
    this.users = const [],
  });

  UsersState copyWith({
    bool? isLoading,
    String? error,
    List<UserModel>? users,
  }) {
    return UsersState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      users: users ?? this.users,
    );
  }
}

class UsersController extends StateNotifier<UsersState> {
  final GetUsersUseCase _getUsers;
  final GetUserByIdUseCase _getUserById;
  final CreateUserUseCase _createUser;
  final UpdateUserUseCase _updateUser;
  final DeleteUserUseCase _deleteUser;

  UsersController({
    required GetUsersUseCase getUsers,
    required GetUserByIdUseCase getUserById,
    required CreateUserUseCase createUser,
    required UpdateUserUseCase updateUser,
    required DeleteUserUseCase deleteUser,
  })  : _getUsers = getUsers,
        _getUserById = getUserById,
        _createUser = createUser,
        _updateUser = updateUser,
        _deleteUser = deleteUser,
        super(UsersState());

  Future<void> fetchUsers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final users = await _getUsers();
      state = state.copyWith(isLoading: false, users: users);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<UserModel?> getUserById(String id) async {
    try {
      return await _getUserById(id);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<bool> createUser(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newUser = await _createUser(data);
      state = state.copyWith(
        isLoading: false,
        users: [...state.users, newUser],
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateUser(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedUser = await _updateUser(id, data);
      state = state.copyWith(
        isLoading: false,
        users: state.users.map((u) => u.id.toString() == id ? updatedUser : u).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteUser(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _deleteUser(id);
      state = state.copyWith(
        isLoading: false,
        users: state.users.where((u) => u.id.toString() != id).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final usersControllerProvider = StateNotifierProvider<UsersController, UsersState>((ref) {
  return UsersController(
    getUsers: ref.watch(getUsersUseCaseProvider),
    getUserById: ref.watch(getUserByIdUseCaseProvider),
    createUser: ref.watch(createUserUseCaseProvider),
    updateUser: ref.watch(updateUserUseCaseProvider),
    deleteUser: ref.watch(deleteUserUseCaseProvider),
  );
});
