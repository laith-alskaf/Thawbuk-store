import { IUser } from "../../../domain/entity/user";
import { UserRepository } from "../../../domain/repository/user.repository";
import { EncryptionService } from "../../../domain/services/encryption.service";
import { TokenService } from "../../../domain/services/token.service";
import { Messages } from "../../../presentation/config/constant";
import { LoginDTO } from "../../dtos/user.dto";
import { BadRequestError } from "../../errors/application-error";

export class LoginUseCase {
    private jwtSecret: string;
    constructor(
        private readonly tokenService: TokenService,
        private readonly userRepository: UserRepository,
        private readonly encryptionService: EncryptionService,


    ) { this.jwtSecret = process.env.JWT_SECRET || 'bW@$3@r%6eR%6!%6mZ%6eR@x'; }
    execute = async (loginData: LoginDTO): Promise<{ token: string, user: IUser }> => {
        const user = await this.userRepository.findByEmail(loginData.email);
        if (!user) {
            throw new BadRequestError(Messages.AUTH.INVALID_CREDENTIALS);
        }
        if (!user.isEmailVerified) {
            throw new BadRequestError(Messages.AUTH.RESEND_VERIFICATION_SUCCESS);
        }
        const isPasswordValid = await this.encryptionService.compare(loginData.password, user.password);
        if (!isPasswordValid) {
            throw new BadRequestError(Messages.AUTH.INVALID_CREDENTIALS);
        }
        const payload = { id: user._id, email: user.email, role: user.role };
        const token = await this.tokenService.generate(payload, this.jwtSecret, '7d');
        user.lastLogin = new Date();
        await this.userRepository.update(user._id, user);

        return { token, user };
    }
}