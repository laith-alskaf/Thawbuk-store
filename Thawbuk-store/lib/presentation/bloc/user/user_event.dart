import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class GetUserProfile extends UserEvent {}

class UpdateUserProfile extends UserEvent {
  final Map<String, dynamic> userData;

  const UpdateUserProfile(this.userData);

  @override
  List<Object> get props => [userData];
}
