import { UserRepository } from "../../../domain/repository/user.repository";
import { EncryptionService } from "../../../domain/services/encryption.service";
import { IdGeneratorService } from "../../../domain/services/id-generator.service";
import { MailService } from "../../../domain/services/mail.service";
import { RandomStringGenerator } from "../../../domain/services/number-generateor.service";
import { RegisterDTO } from "../../dtos/user.dto";
import { VERIFICATION_EMAIL_TEMPLATE } from "../../../domain/emails_template/verification_email_template";
import { BadRequestError, ConflictRequestError } from "../../errors/application-error";
import { Messages, UserRoles } from "../../../presentation/config/constant";

export class RegisterUseCase {
    private otpCodeExpiresAt = new Date(Date.now() + 10 * 60 * 1000);
    constructor(
        private readonly emailService: MailService,
        private readonly userRepository: UserRepository,
        private readonly encryptionService: EncryptionService,
        private readonly otpGeneratorService: RandomStringGenerator,
        private readonly uuidGeneratorService: IdGeneratorService,
    ) { }
    execute = async (registerData: RegisterDTO): Promise<void> => {
        const existingUser = await this.userRepository.findByEmail(registerData.email);
        if (existingUser) {
            if (!existingUser.isEmailVerified) {
                throw new BadRequestError(Messages.AUTH.VERIFICATION_REQUIRED_EN);
            }
            else {
                throw new ConflictRequestError(Messages.AUTH.USERNAME_ALREADY_EXISTS_EN);
            }
        }
        if (registerData.role == UserRoles.SUPER_ADMIN) {
            const existingSuperAdmin = await this.userRepository.findByEmail(UserRoles.SUPER_ADMIN);
            if (existingSuperAdmin) {
                throw new ConflictRequestError("SuperAdmin already exists");
            }
        }
        const hashedPassword = await this.encryptionService.hash(registerData.password);
        const otpCode = this.otpGeneratorService.generate();
        registerData.password = hashedPassword;
        const user = {
            ...registerData,
            _id: this.uuidGeneratorService.generate(),
            otpCode: otpCode,
            otpCodeExpires: this.otpCodeExpiresAt,
            isEmailVerified: false // Require email verification
        };
        await this.userRepository.create(user);
        await this.emailService.send(registerData.email, 'تأكيد البريد الإلكتروني - متجر ثوبك', VERIFICATION_EMAIL_TEMPLATE.replace("{verificationCode}", otpCode))
    }
}
