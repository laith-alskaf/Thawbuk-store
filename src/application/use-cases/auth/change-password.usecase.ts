import { PASSWORD_RESET_SUCCESS_TEMPLATE } from "../../../domain/emails_template/reset_password_success_template";
import { UserRepository } from "../../../domain/repository/user.repository";
import { EncryptionService } from "../../../domain/services/encryption.service";
import { MailService } from "../../../domain/services/mail.service";
import { ChangePasswordDTO } from "../../dtos/user.dto";

export class ChangePasswordUseCase {
    constructor(
        private readonly userRepository: UserRepository,
        private readonly encryptionService: EncryptionService,
        private readonly mailService: MailService,
    ) { }
    execute = async (changePasswordDTO: ChangePasswordDTO): Promise<void> => {
        const user = await this.userRepository.findByEmail(changePasswordDTO.email);
        if (!user) {
            throw new Error('User not found');
        }
        const hashedPassword = await this.encryptionService.hash(changePasswordDTO.newPassword);
        user.password = hashedPassword;
        user.otpCodeExpires = new Date("00");
        user.otpCode = '';
        this.userRepository.update(user._id, user);
        this.mailService.send(user.email, "Password Reset Successful", PASSWORD_RESET_SUCCESS_TEMPLATE);

    }
}