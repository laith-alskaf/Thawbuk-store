
import { Request, Response } from "express"

import { CONFIG } from "../config/env";
import { Messages, StatusCodes } from "../config/constant";

import {
    GetUserInfoUseCase,
    UpdateUserInfoUseCase,
    DeleteUserAccountUseCase,
} from "../../application/use-cases/user";

import { UserInfoDTO } from "../../application/dtos/user.dto";

import { ApplicationResponse } from "../../application/response/application-resposne";


export class UserController {
    constructor(
        private readonly getUserInfoUseCase: GetUserInfoUseCase,
        private readonly updateUserInfoUseCase: UpdateUserInfoUseCase,
        private readonly deleteUserAccountUseCase: DeleteUserAccountUseCase,
    ) { }

    getUserInfo = async (req: Request, res: Response): Promise<void> => {
        try {

            const userId = req.user.id
            const userInfo = await this.getUserInfoUseCase.execute(userId)

            return new ApplicationResponse(res, {
                statusCode: StatusCodes.OK,
                success: true,
                message: Messages.USER.GET_INFO_SUCCESS_EN,
                body: { user: userInfo },
            }).send()

        } catch (error) {
            throw error
        }
    };

    updateUserInfo = async (req: Request, res: Response): Promise<void> => {
        try {
            const userId = req.user.id;
            const { userName, email, role } = req.body;

            const updatedUserData: Partial<UserInfoDTO> = {
                ...(userName && { userName }),
                ...(email && { email }),
                ...(role && { role }),
            };

            const updatedUserInfo = await this.updateUserInfoUseCase.execute(userId, updatedUserData);

            return new ApplicationResponse(res, {
                statusCode: StatusCodes.OK,
                success: true,
                message: Messages.USER.UPDATE_INFO_SUCCESS_EN,
                body: { user: updatedUserInfo },
            }).send();

        } catch (error) {
            throw error;
        }
    };

    deleteAccount = async (req: Request, res: Response): Promise<void> => {
        try {
            const userId = req.user.id;
            await this.deleteUserAccountUseCase.execute(userId);

            return new ApplicationResponse(res, {
                statusCode: StatusCodes.OK,
                success: true,
                message: Messages.USER.DELETE_ACCOUNT_SUCCESS_EN,
            }).send();

        } catch (error) {
            throw error;
        }
    };

}




