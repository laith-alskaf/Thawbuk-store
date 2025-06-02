import { VERIFICATION_EMAIL_TEMPLATE } from "../../../domain/emails_template/verification_email_template";
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
        await this.emailService.send(user.email, 'Verify your email', VERIFICATION_EMAIL_TEMPLATE.replace("verificationCode", otpCode))
    }
}