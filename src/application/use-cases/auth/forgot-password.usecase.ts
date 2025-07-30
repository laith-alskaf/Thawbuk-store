import { PASSWORD_RESET_REQUEST_TEMPLATE } from "../../../domain/emails_template/reset_password_template";
import { UserRepository } from "../../../domain/repository/user.repository";
import { MailService } from "../../../domain/services/mail.service";
import { RandomStringGenerator } from "../../../domain/services/number-generateor.service";
import { ForgotPasswordDTO, } from "../../dtos/user.dto";

export class ForgotPasswordUseCase {
    private otpCodeExpiresAt = new Date(Date.now() + 10 * 60 * 1000);
    constructor(
        private readonly userRepository: UserRepository,
        private readonly emailService: MailService,
        private readonly otpGeneratorService: RandomStringGenerator,
    ) { }
    execute = async (forgotPasswordDTO: ForgotPasswordDTO): Promise<void> => {
        const user = await this.userRepository.findByEmail(forgotPasswordDTO.email);
        if (!user) {
            throw new Error("User not found");
        }
        const otpCode = this.otpGeneratorService.generate();
        const updateOTPUser = {
            otpCode: otpCode,
            otpCodeExpires: this.otpCodeExpiresAt
        };
        await this.userRepository.update(user._id, updateOTPUser);
        await this.emailService.send(user.email, 'إعادة تعيين كلمة المرور - متجر ثوبك', PASSWORD_RESET_REQUEST_TEMPLATE.replace("{resetURL}", `${process.env.FRONTEND_URL}/reset-password?token=${otpCode}`))
    }
}