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
        message: Messages.AUTH.REGISTER_SUCCESS_EN,
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
        message: Messages.AUTH.LOGIN_SUCCESS_EN,
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
      message: Messages.AUTH.LOGOUT_SUCCESS_EN || "Logged out successfully"
    }).send();
  }


  async forgotPassword(req: Request, res: Response): Promise<void> {
    try {
      const forgotPasswordDTO: ForgotPasswordDTO = req.body;
      await this.forgotPasswordUseCase.execute(forgotPasswordDTO);
      new ApplicationResponse(res, {
        success: true,
        statusCode: StatusCodes.OK,
        message: Messages.AUTH.FORGOT_PASSWORD_SUCCESS_EN
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
        message: Messages.AUTH.VERIFY_SUCCESS_EN
      }).send();
    } catch (error: any) {
      throw new BadRequestError(error.message);
    }
  }


  async changePassword(req: Request, res: Response): Promise<void> {
    try {
      const changePasswordDTO: ChangePasswordDTO = req.body;
      await this.changePasswordUseCase.execute(changePasswordDTO);
      new ApplicationResponse(res, {
        success: true,
        statusCode: StatusCodes.OK,
        message: Messages.AUTH.RESET_PASSWORD_SUCCESS_EN
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