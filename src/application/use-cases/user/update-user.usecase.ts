
import { UserInfoDTO } from "../../dtos/user.dto";

import { UserRepository } from "../../../domain/repository/user.repository";

export class UpdateUserInfoUseCase {

    constructor(
        private readonly userRepository: UserRepository,
    ) { }

    execute = async (userId: string, userData: Partial<UserInfoDTO>): Promise<UserInfoDTO | null> => {
        const user = await this.userRepository.update(userId, userData);

        if (!user) {
            return null;
        }

        const userInfo: UserInfoDTO = {
            name: user.name,
            email: user.email,
            role: user.role,
            age: user.age,
            gender: user.gender,
            companyDetails: user.companyDetails,
            address: user.address,
            fcmToken: user.fcmToken,
        }
        return userInfo;
    }
}
