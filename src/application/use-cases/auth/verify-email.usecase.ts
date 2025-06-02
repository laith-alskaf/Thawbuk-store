import { WELCOME_EMAIL_TEMPLATE } from "../../../domain/emails_template/welcome_email_template";
import { UserRepository } from "../../../domain/repository/user.repository";
import { MailService } from "../../../domain/services/mail.service";
import { VerifyEmailDTO } from "../../dtos/user.dto";

export class VerifiyEmailUseCase {
    constructor(
        private readonly emailService: MailService,
        private readonly userRepository: UserRepository,
    ) { }
    execute = async (verifyEmailDTO: VerifyEmailDTO): Promise<void> => {
        const user = await this.userRepository.findByCode(verifyEmailDTO.code);
        if (!user) throw new Error("Invalid or expired verification code");

        if (user.otpCodeExpires < new Date()) {
            throw new Error("Expired verification code");
        }
        user.otpCodeExpires = new Date("00");
        user.otpCode = '';
        user.isEmailVerified = true;
        await this.userRepository.update(user._id, user);
        await this.emailService.send(user.email, 'Welcome Email', WELCOME_EMAIL_TEMPLATE.replace("{USER_NAME}", user.userName))
    }
}