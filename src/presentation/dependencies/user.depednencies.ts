import { UserRepository } from '../../domain/repository/user.repository';
import { UserController } from '../controllers/user.controllers';

import {
    GetUserInfoUseCase,
    DeleteUserAccountUseCase,
    UpdateUserInfoUseCase
} from "../../application/use-cases/user";


interface UserDependenciesType {
    userRepository: UserRepository;
}

export const UserDependencies = ({
    userRepository,
}: UserDependenciesType): UserController => {

    // Use Cases
    const getUserInfoUseCase = new GetUserInfoUseCase(userRepository);
    const deleteUserAccountUseCase = new DeleteUserAccountUseCase(userRepository);
    const updateUserInfoUseCase = new UpdateUserInfoUseCase(userRepository);

    const userController: UserController = new UserController(
        getUserInfoUseCase,
        updateUserInfoUseCase,
        deleteUserAccountUseCase,
    );


    return userController;


}