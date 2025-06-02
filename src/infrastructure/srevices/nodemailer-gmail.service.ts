import nodemailer from "nodemailer";

import { Attachment, MailService } from "../../domain/services/mail.service";

export class NodemailerGmailService implements MailService {
    constructor(
        private readonly user: string,
        private readonly pass: string

    ) { }

    send = async (to: string, subject: string, template: string, attachments?: Attachment[]): Promise<void> => {
        try {
            const transporter = nodemailer.createTransport({
                service: "gmail",
                auth: {
                    user: this.user,
                    pass: this.pass,
                },
            });

            const mailOptions = {
                from: this.user,
                to,
                subject,
                html: template,
                attachments,
            };

            await transporter.sendMail(mailOptions);
        } catch (error) {
            throw new Error("Email sending failed");
        }
    }
}
