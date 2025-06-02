import { UserInfoDTO } from "../../dtos/user.dto";
import { BadRequestError } from "../../errors/application-error";

import { UserRepository } from "../../../domain/repository/user.repository";
import { Messages } from "../../../presentation/config/constant";


export class GetUserInfoUseCase {

    constructor(
        private readonly userRepository: UserRepository,
    ) { }

    execute = async (userId: string): Promise<UserInfoDTO> => {

        const user = await this.userRepository.findById(userId);

        if (!user) {
            throw new BadRequestError(Messages.USER.USER_NOT_FOUND_EN);
        }
        const userInfo: UserInfoDTO = {
            userName: user.userName,
            email: user.email,
            role: user.role,
        }

        return userInfo
    };
}
