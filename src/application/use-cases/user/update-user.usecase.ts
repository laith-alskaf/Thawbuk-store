
import { UserInfoDTO } from "../../dtos/user.dto";

import { UserRepository } from "../../../domain/repository/user.repository";

export class UpdateUserInfoUseCase {

    constructor(
        private readonly userRepository: UserRepository,
    ) { }

    execute = async (userId: string, userData: Partial<UserInfoDTO>): Promise<UserInfoDTO | null> => {
        const user = await this.userRepository.update(userId, userData);

        const userInfo: UserInfoDTO = {
            userName: user?.userName!,
            email: user?.email!,
            role: user?.role!,
        }
        return userInfo;
    }
}
