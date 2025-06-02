import { Request, Response } from "express";
import { Messages, StatusCodes } from "../config/constant";
import {
    RemoveAllProductfromWishlistUseCase,
    RemoveProductFromWishlistUseCase,
    GetWishlistUseCase,
    AddProductToWishlistUseCase,
} from "../../application/use-cases/wishlist";
import { ApplicationResponse } from "../../application/response/application-resposne";
import { BadRequestError } from "../../application/errors/application-error";
export class WishlistController {

    constructor(
        private readonly addProductToWishlistUseCase: AddProductToWishlistUseCase,
        private readonly getWishlistUseCase: GetWishlistUseCase,
        private readonly removeAllProductfromWishlistUseCase: RemoveAllProductfromWishlistUseCase,
        private readonly removeProductFromWishlistUseCase: RemoveProductFromWishlistUseCase,
    ) { }

    async getWishlist(req: Request, res: Response): Promise<void> {
        try {
            const userId = req.user.id;
            const wishlist = await this.getWishlistUseCase.execute(userId);
            new ApplicationResponse(res, {
                success: true,
                statusCode: StatusCodes.OK, message: Messages.WISHLIST.GET_SUCCESS_EN,
                body: wishlist
            }).send();

        } catch (error: any) {
            throw new BadRequestError(error.message);
        }

    }

    async addProdutcToWishlist(req: Request, res: Response): Promise<void> {
        try {
            const { productId } = req.params;
            console.log(productId);
            const userId = req.user.id;
            await this.addProductToWishlistUseCase.execute(userId, productId);
            new ApplicationResponse(res, {
                success: true,
                statusCode: StatusCodes.OK, message: Messages.WISHLIST.ADD_SUCCESS_EN,
            }).send();
        } catch (error: any) {
            throw new BadRequestError(error.message);
        }

    }

    async removeProdutcFromWishlist(req: Request, res: Response): Promise<void> {
        try {
            const { productId } = req.params;
            const userId = req.user?.id;
            await this.removeProductFromWishlistUseCase.execute(userId, productId);
            new ApplicationResponse(res, {
                success: true,
                statusCode: StatusCodes.OK, message: Messages.WISHLIST.REMOVE_SUCCESS_EN,
            }).send();
        } catch (error: any) {
            throw new BadRequestError(error.message);
        }

    }


    async removeAllProdutcFromWishlist(req: Request, res: Response): Promise<void> {
        try {
            const userId = req.user?.id;
            await this.removeAllProductfromWishlistUseCase.execute(userId!);
            new ApplicationResponse(res, {
                success: true,
                statusCode: StatusCodes.OK, message: Messages.WISHLIST.CLEAR_SUCCESS_EN,
            }).send();
        } catch (error: any) {
            throw new BadRequestError(error.message);
        }

    }
}
