import { Request, Response } from 'express';
import { ChangePasswordDTO, ForgotPasswordDTO, LoginDTO, RegisterDTO, VerifyEmailDTO } from '../../application/dtos/user.dto';
import { Messages, StatusCodes } from '../config/constant';
import {
  LoginUseCase,
  RegisterUseCase,
  VerifiyEmailUseCase as VerifyEmailUseCase,
  ChangePasswordUseCase,
  ForgotPasswordUseCase,
} from "../../application/use-cases/auth";
import { ResendVerificationUseCase } from "../../application/use-cases/auth/resend-verification.usecase";
import { ApplicationResponse } from '../../application/response/application-resposne';
import { BadRequestError } from '../../application/errors/application-error';


export class AuthController {

  constructor(
    private readonly registerUseCase: RegisterUseCase,
    private readonly loginUseCase: LoginUseCase,
    private readonly forgotPasswordUseCase: ForgotPasswordUseCase,
    private readonly verifyEmailUseCase: VerifyEmailUseCase,
    private readonly changePasswordUseCase: ChangePasswordUseCase,
    private readonly resendVerificationUseCase: ResendVerificationUseCase,
  ) { }


  async register(req: Request, res: Response): Promise<void> {
    try {
      const registerData: RegisterDTO = req.body;
      await this.registerUseCase.execute(registerData);
      new ApplicationResponse(res, {
        success: true,
        statusCode: StatusCodes.CREATED,
        message: Messages.AUTH.REGISTER_SUCCESS,
      }).send();

    } catch (error: any) {
      throw new BadRequestError(error.message);
    }
  }


  async login(req: Request, res: Response): Promise<void> {
    try {
      const loginData: LoginDTO = req.body;
      const { token, user } = await this.loginUseCase.execute(loginData);
      
      new ApplicationResponse(res, {
        success: true,
        statusCode: StatusCodes.OK,
        message: Messages.AUTH.LOGIN_SUCCESS,
        body: {
          token,
          userInfo: {
            id: user._id,
            userName: user.name,
            email: user.email,
            role: user.role,
          }
        }
      }).send();
    } catch (error: any) {
      throw new BadRequestError(error.message);
    }
  }


  async logout(_req: Request, res: Response): Promise<void> {
    new ApplicationResponse(res, {
      success: true,
      statusCode: StatusCodes.OK,
      message: Messages.AUTH.LOGOUT_SUCCESS || "Logged out successfully"
    }).send();
  }


  async forgotPassword(req: Request, res: Response): Promise<void> {
    try {
      const forgotPasswordDTO: ForgotPasswordDTO = req.body;
      await this.forgotPasswordUseCase.execute(forgotPasswordDTO);
      new ApplicationResponse(res, {
        success: true,
        statusCode: StatusCodes.OK,
        message: Messages.AUTH.FORGOT_PASSWORD_SUCCESS
      }).send();
    } catch (error: any) {
      throw new BadRequestError(error.message);
    }
  }


  async verifyEmail(req: Request, res: Response): Promise<void> {
    try {
      const verifyEmailDTO: VerifyEmailDTO = req.body;
      await this.verifyEmailUseCase.execute(verifyEmailDTO);
      new ApplicationResponse(res, {
        success: true,
        statusCode: StatusCodes.OK,
        message: Messages.AUTH.VERIFY_SUCCESS
      }).send();
    } catch (error: any) {
      throw new BadRequestError(error.message);
    }
  }

  // New method for email verification via link
  async verifyEmailViaLink(req: Request, res: Response): Promise<void> {
    try {
      const { token, email } = req.body;
      
      if (!token || !email) {
        throw new BadRequestError('Token and email are required');
      }

      // Use the existing verify email use case with token as otpCode
      const verifyEmailDTO: VerifyEmailDTO = {
        email: email,
        otpCode: token
      };
      
      await this.verifyEmailUseCase.execute(verifyEmailDTO);
      
      new ApplicationResponse(res, {
        success: true,
        statusCode: StatusCodes.OK,
        message: Messages.AUTH.VERIFY_SUCCESS
      }).send();
    } catch (error: any) {
      throw new BadRequestError(error.message);
    }
  }

  // Method to serve the email verification page
  async showVerificationPage(req: Request, res: Response): Promise<void> {
    try {
      const { token, email } = req.query;
      
      if (!token || !email) {
        return res.status(400).send(`
          <html>
            <body style="font-family: Arial, sans-serif; text-align: center; padding: 50px;">
              <h1>رابط التحقق غير صحيح</h1>
              <p>يرجى التأكد من الرابط والمحاولة مرة أخرى</p>
            </body>
          </html>
        `);
      }

      // Read and serve the verification HTML page
      const path = require('path');
      const fs = require('fs');
      const htmlPath = path.join(__dirname, '../views/email-verification.html');
      
      if (fs.existsSync(htmlPath)) {
        const html = fs.readFileSync(htmlPath, 'utf8');
        res.send(html);
      } else {
        // Fallback HTML if file doesn't exist
        res.send(`
          <!DOCTYPE html>
          <html lang="ar" dir="rtl">
          <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <title>تأكيد البريد الإلكتروني - متجر ثوبك</title>
              <style>
                  body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
                  .container { max-width: 500px; margin: 0 auto; }
                  .btn { padding: 10px 20px; background: #6366f1; color: white; text-decoration: none; border-radius: 5px; }
              </style>
          </head>
          <body>
              <div class="container">
                  <h1>تأكيد البريد الإلكتروني</h1>
                  <p>جاري التحقق من بريدك الإلكتروني...</p>
                  <script>
                      const token = '${token}';
                      const email = '${email}';
                      
                      fetch('/api/auth/verify-email', {
                          method: 'POST',
                          headers: { 'Content-Type': 'application/json' },
                          body: JSON.stringify({ token, email })
                      })
                      .then(response => response.json())
                      .then(data => {
                          if (data.success) {
                              document.body.innerHTML = '<div class="container"><h1>تم تأكيد البريد الإلكتروني بنجاح!</h1><p>يمكنك الآن تسجيل الدخول إلى التطبيق</p><a href="thawbukstore://login" class="btn">فتح التطبيق</a></div>';
                          } else {
                              document.body.innerHTML = '<div class="container"><h1>فشل في التحقق</h1><p>' + data.message + '</p></div>';
                          }
                      })
                      .catch(error => {
                          document.body.innerHTML = '<div class="container"><h1>حدث خطأ</h1><p>يرجى المحاولة مرة أخرى</p></div>';
                      });
                  </script>
              </div>
          </body>
          </html>
        `);
      }
    } catch (error: any) {
      res.status(500).send(`
        <html>
          <body style="font-family: Arial, sans-serif; text-align: center; padding: 50px;">
            <h1>حدث خطأ</h1>
            <p>يرجى المحاولة مرة أخرى لاحقاً</p>
          </body>
        </html>
      `);
    }
  }


  async changePassword(req: Request, res: Response): Promise<void> {
    try {
      const changePasswordDTO: ChangePasswordDTO = req.body;
      await this.changePasswordUseCase.execute(changePasswordDTO);
      new ApplicationResponse(res, {
        success: true,
        statusCode: StatusCodes.OK,
        message: Messages.AUTH.RESET_PASSWORD_SUCCESS
      }).send();
    } catch (error: any) {
      throw new BadRequestError(error.message);
    }
  }

  async resendVerification(req: Request, res: Response): Promise<void> {
    try {
      const { email } = req.body;
      await this.resendVerificationUseCase.execute(email);
      new ApplicationResponse(res, {
        success: true,
        statusCode: StatusCodes.OK,
        message: "تم إعادة إرسال رمز التحقق بنجاح"
      }).send();
    } catch (error: any) {
      throw new BadRequestError(error.message);
    }
  }
}
