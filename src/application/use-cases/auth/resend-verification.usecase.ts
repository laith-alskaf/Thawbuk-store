import { VERIFICATION_EMAIL_TEMPLATE } from "../../../domain/emails_template/verification_email_template";
import { UserRepository } from "../../../domain/repository/user.repository";
import { MailService } from "../../../domain/services/mail.service";
import { RandomStringGenerator } from "../../../domain/services/number-generateor.service";
import { BadRequestError } from "../../errors/application-error";
import { Messages } from "../../../presentation/config/constant";

export class ResendVerificationUseCase {
    private otpCodeExpiresAt = new Date(Date.now() + 10 * 60 * 1000);
    
    constructor(
        private readonly userRepository: UserRepository,
        private readonly emailService: MailService,
        private readonly otpGeneratorService: RandomStringGenerator,
    ) { }
    
    execute = async (email: string): Promise<void> => {
        const user = await this.userRepository.findByEmail(email);
        if (!user) {
            throw new BadRequestError("User not found");
        }
        
        if (user.isEmailVerified) {
            throw new BadRequestError("Email already verified");
        }
        
        const otpCode = this.otpGeneratorService.generate();
        const updateOTPUser = {
            otpCode: otpCode,
            otpCodeExpires: this.otpCodeExpiresAt
        };
        
        await this.userRepository.update(user._id, updateOTPUser);
        await this.emailService.send(
            user.email, 
            'تأكيد البريد الإلكتروني - متجر ثوبك', 
            VERIFICATION_EMAIL_TEMPLATE.replace("{verificationCode}", otpCode)
        );
    }
}