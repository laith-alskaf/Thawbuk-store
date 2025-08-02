
import { Request, Response } from "express"

import { CONFIG } from "../config/env";
import { Messages, StatusCodes } from "../config/constant";

import {
    GetUserInfoUseCase,
    UpdateUserInfoUseCase,
    DeleteUserAccountUseCase,
} from "../../application/use-cases/user";

import { UserInfoDTO, UpdateSocialLinksDTO } from "../../application/dtos/user.dto";

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
            const { 
                name, 
                email, 
                companyDetails, 
                address, 
                age, 
                gender 
            } = req.body;

            // Build update data - explicitly exclude role and other sensitive fields
            const updatedUserData: Partial<UserInfoDTO> = {};
            
            if (name) updatedUserData.name = name;
            if (email) updatedUserData.email = email;
            if (companyDetails) updatedUserData.companyDetails = companyDetails;
            if (address) updatedUserData.address = address;
            if (age) updatedUserData.age = age;
            if (gender) updatedUserData.gender = gender;

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

    updateSocialLinks = async (req: Request, res: Response): Promise<void> => {
        try {
            const userId = req.user.id;
            const socialLinksData: UpdateSocialLinksDTO = req.body;

            // Get current user to preserve existing company details
            const currentUser = await this.getUserInfoUseCase.execute(userId);
            
            if (!currentUser || !currentUser.companyDetails) {
                return new ApplicationResponse(res, {
                    statusCode: StatusCodes.BAD_REQUEST,
                    success: false,
                    message: "لا يمكن تحديث روابط التواصل الاجتماعي للمستخدمين غير أصحاب المتاجر",
                }).send();
            }

            const updatedCompanyDetails = {
                ...currentUser.companyDetails,
                socialLinks: socialLinksData
            };

            const updatedUser = await this.updateUserInfoUseCase.execute(userId, {
                companyDetails: updatedCompanyDetails
            });

            return new ApplicationResponse(res, {
                statusCode: StatusCodes.OK,
                success: true,
                message: "تم تحديث روابط التواصل الاجتماعي بنجاح",
                body: { user: updatedUser },
            }).send();

        } catch (error) {
            throw error;
        }
    };

}




