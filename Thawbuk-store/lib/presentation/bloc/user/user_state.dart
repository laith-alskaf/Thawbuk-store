import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserProfileLoaded extends UserState {
  final UserEntity user;

  const UserProfileLoaded(this.user);

  @override
  List<Object> get props => [user];
}

class UserProfileUpdateSuccess extends UserState {
    final UserEntity user;

  const UserProfileUpdateSuccess(this.user);

  @override
  List<Object> get props => [user];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object> get props => [message];
}
