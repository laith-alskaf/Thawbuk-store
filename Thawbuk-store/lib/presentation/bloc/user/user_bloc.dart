import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/usecases/user/get_user_profile_usecase.dart';
import '../../../domain/usecases/user/update_user_profile_usecase.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;

  UserBloc({
    required this.getUserProfileUseCase,
    required this.updateUserProfileUseCase,
  }) : super(UserInitial()) {
    on<GetUserProfile>(_onGetUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
  }

  Future<void> _onGetUserProfile(
    GetUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    final failureOrUser = await getUserProfileUseCase(NoParams());
    failureOrUser.fold(
      (failure) => emit(UserError(failure.message)),
      (user) => emit(UserProfileLoaded(user)),
    );
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    final failureOrUser = await updateUserProfileUseCase(
      UpdateUserParams(userData: event.userData),
    );

    failureOrUser.fold(
      (failure) => emit(UserError(failure.message)),
      (user) => emit(UserProfileUpdateSuccess(user)),
    );
  }
}
