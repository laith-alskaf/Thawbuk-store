import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/register_usecase.dart';
import '../../../domain/usecases/auth/logout_usecase.dart';
import '../../../domain/usecases/auth/verify_email_usecase.dart';
import '../../../domain/usecases/auth/resend_verification_usecase.dart';
import '../../../domain/usecases/auth/forgot_password_usecase.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final Map<String, dynamic> userData;

  const RegisterEvent({
    required this.userData,
  });

  @override
  List<Object> get props => [userData];
}

class LogoutEvent extends AuthEvent {}

class VerifyEmailEvent extends AuthEvent {
  final String code;
  final String? email;

  const VerifyEmailEvent({required this.code, this.email});

  @override
  List<Object> get props => [code];
}

class ResendVerificationCodeEvent extends AuthEvent {
  final String email;

  const ResendVerificationCodeEvent({required this.email});

  @override
  List<Object> get props => [email];
}

class ForgotPasswordEvent extends AuthEvent {
  final String email;

  const ForgotPasswordEvent({required this.email});

  @override
  List<Object> get props => [email];
}

class ContinueAsGuestEvent extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthGuest extends AuthState {}

class AuthEmailVerified extends AuthState {}

class ForgotPasswordSent extends AuthState {
  final String email;

  const ForgotPasswordSent({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthRegistrationSuccess extends AuthState {
  final String email;

  const AuthRegistrationSuccess({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final AuthRepository authRepository;
  final VerifyEmailUseCase verifyEmailUseCase;
  final ResendVerificationUseCase resendVerificationUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.authRepository,
    required this.verifyEmailUseCase,
    required this.resendVerificationUseCase,
    required this.forgotPasswordUseCase,
  }) : super(AuthInitial()) {
    
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<VerifyEmailEvent>(_onVerifyEmail);
    on<ResendVerificationCodeEvent>(_onResendVerificationCode);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<ContinueAsGuestEvent>(_onContinueAsGuest);

    // Check auth status on startup
    add(CheckAuthStatusEvent());
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final isLoggedIn = await authRepository.isUserLoggedIn();
      if (isLoggedIn) {
        final result = await authRepository.getCurrentUser();
        result.fold(
          (failure) => emit(AuthUnauthenticated()),
          (user) => emit(AuthAuthenticated(user)),
        );
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await loginUseCase(LoginParams(
      email: event.email,
      password: event.password,
    ));

    result.fold(
      (failure) {
        String message = 'حدث خطأ أثناء تسجيل الدخول';
        if (failure is ServerFailure) {
          message = failure.message;
        } else if (failure is NetworkFailure) {
          message = 'تحقق من اتصال الإنترنت';
        }
        emit(AuthError(message));
      },
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await registerUseCase(RegisterParams(
      userData: event.userData,
    ));

    result.fold(
      (failure) {
        String message = 'حدث خطأ أثناء إنشاء الحساب';
        if (failure is ServerFailure) {
          message = failure.message;
        } else if (failure is NetworkFailure) {
          message = 'تحقق من اتصال الإنترنت';
        }
        emit(AuthError(message));
      },
      (success) => emit(AuthRegistrationSuccess(email: event.userData['email'])),
    );
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // تنظيف البيانات المحلية أولاً
      await _clearLocalData();
      
      // ثم استدعاء logout من الخادم
      final result = await logoutUseCase(NoParams());

      result.fold(
        (failure) {
          // حتى لو فشل logout من الخادم، نظف البيانات المحلية
          emit(AuthUnauthenticated());
        },
        (_) => emit(AuthUnauthenticated()),
      );
    } catch (e) {
      // في حالة أي خطأ، تأكد من تنظيف البيانات
      await _clearLocalData();
      emit(AuthUnauthenticated());
    }
  }

  /// تنظيف جميع البيانات المحلية
  Future<void> _clearLocalData() async {
    try {
      // مسح التوكن والبيانات المحفوظة
      await authRepository.logout();
      
      // تنظيف إضافي للبيانات:
      // TODO: إضافة تنظيف بيانات السلة
      // TODO: إضافة تنظيف بيانات المفضلة
      // TODO: إضافة تنظيف الكاش
      
      // إرسال إشعار لباقي الـ BLoCs لتنظيف بياناتها
      // يمكن استخدام EventBus أو Stream للتواصل بين BLoCs
      
    } catch (e) {
      // تجاهل الأخطاء في التنظيف - المهم هو تسجيل الخروج
      print('Error clearing local data: $e');
    }
  }

  Future<void> _onVerifyEmail(
    VerifyEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await verifyEmailUseCase(VerifyEmailParams(
      code: event.code,
    ));

    result.fold(
      (failure) {
        String message = 'حدث خطأ أثناء التحقق من البريد الإلكتروني';
        if (failure is ServerFailure) {
          message = failure.message;
        } else if (failure is NetworkFailure) {
          message = 'تحقق من اتصال الإنترنت';
        }
        emit(AuthError(message));
      },
      (_) => emit(AuthEmailVerified()),
    );
  }

  Future<void> _onResendVerificationCode(
    ResendVerificationCodeEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await resendVerificationUseCase(
      ResendVerificationParams(email: event.email),
    );
    
    result.fold(
      (failure) {
        String message = 'حدث خطأ أثناء إعادة إرسال الرمز';
        if (failure is ServerFailure) {
          message = failure.message;
        } else if (failure is NetworkFailure) {
          message = 'تحقق من اتصال الإنترنت';
        }
        emit(AuthError(message));
      },
      (_) => emit(AuthRegistrationSuccess(email: event.email)),
    );
  }

  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await forgotPasswordUseCase(
      ForgotPasswordParams(email: event.email),
    );
    
    result.fold(
      (failure) {
        String message = 'حدث خطأ أثناء إرسال رابط استعادة كلمة المرور';
        if (failure is ServerFailure) {
          message = failure.message;
        } else if (failure is NetworkFailure) {
          message = 'تحقق من اتصال الإنترنت';
        }
        emit(AuthError(message));
      },
      (_) => emit(ForgotPasswordSent(email: event.email)),
    );
  }

  Future<void> _onContinueAsGuest(
    ContinueAsGuestEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthGuest());
  }
}
