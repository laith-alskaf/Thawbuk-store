import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/user.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/register_usecase.dart';
import '../../../domain/usecases/auth/logout_usecase.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../core/usecases/usecase.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String? name;
  final String role;
  final int? age;
  final String? gender;

  const RegisterEvent({
    required this.email,
    required this.password,
    this.name,
    this.role = 'customer',
    this.age,
    this.gender,
  });

  @override
  List<Object?> get props => [email, password, name, role, age, gender];
}

class LogoutEvent extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthenticatedState extends AuthState {
  final User user;
  final String token;

  const AuthenticatedState({required this.user, required this.token});

  @override
  List<Object?> get props => [user, token];
}

class UnauthenticatedState extends AuthState {}

class AuthErrorState extends AuthState {
  final String message;

  const AuthErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.authRepository,
  }) : super(AuthInitialState()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    final isLoggedIn = await authRepository.isLoggedIn();
    
    if (isLoggedIn) {
      try {
        final result = await authRepository.getCurrentUser();
        result.fold(
          (failure) => emit(UnauthenticatedState()),
          (user) {
            final token = authRepository.getAuthToken();
            emit(AuthenticatedState(user: user, token: token.toString()));
          },
        );
      } catch (e) {
        emit(UnauthenticatedState());
      }
    } else {
      emit(UnauthenticatedState());
    }
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    
    final result = await loginUseCase(LoginParams(
      email: event.email,
      password: event.password,
    ));
    
    result.fold(
      (failure) => emit(AuthErrorState(message: failure.message)),
      (authData) {
        // حفظ التوكن والمستخدم
        final token = authData['token'] as String;
        final userInfo = authData['userInfo'] as Map<String, dynamic>;
        
        authRepository.saveAuthToken(token);
        
        // يجب تحويل userInfo إلى User object
        // مؤقتاً سنستخدم بيانات وهمية
        const user = User(
          id: '1',
          email: 'test@test.com',
          role: 'customer',
          isEmailVerified: true,
          lastLogin: '2024-01-01',
          createdAt: '2024-01-01',
          updatedAt: '2024-01-01',
        );
        
        emit(AuthenticatedState(user: user, token: token));
      },
    );
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    
    final result = await registerUseCase(RegisterParams(
      email: event.email,
      password: event.password,
      name: event.name,
      role: event.role,
      age: event.age,
      gender: event.gender,
    ));
    
    result.fold(
      (failure) => emit(AuthErrorState(message: failure.message)),
      (_) {
        emit(UnauthenticatedState());
        // يمكن إضافة رسالة نجح التسجيل هنا
      },
    );
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    
    final result = await logoutUseCase(NoParams());
    
    result.fold(
      (failure) => emit(AuthErrorState(message: failure.message)),
      (_) {
        authRepository.clearAuthData();
        emit(UnauthenticatedState());
      },
    );
  }
}