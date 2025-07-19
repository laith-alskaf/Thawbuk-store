import { Request, Response } from 'express';
import { AddItemToCartDTO, UpdateCartItemDTO } from '../../application/dtos/cart.dto';
import { Messages, StatusCodes } from '../config/constant';
import {
  AddItemToCartUseCase,
  GetCartUseCase,
  UpdateCartItemUseCase,
  RemoveFromCartUseCase,
  ClearCartUseCase
} from '../../application/use-cases/cart';
import { ApplicationResponse } from '../../application/response/application-resposne';
import { BadRequestError } from '../../application/errors/application-error';

export class CartController {
  constructor(
    private readonly addItemToCartUseCase: AddItemToCartUseCase,
    private readonly getCartUseCase: GetCartUseCase,
    private readonly updateCartItemUseCase: UpdateCartItemUseCase,
    private readonly removeFromCartUseCase: RemoveFromCartUseCase,
    private readonly clearCartUseCase: ClearCartUseCase
  ) {}

  async addToCart(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user.id;
      const itemData: AddItemToCartDTO = req.body;
      
      const cart = await this.addItemToCartUseCase.execute(userId, itemData);
      
      new ApplicationResponse(res, {
        success: true,
        statusCode: StatusCodes.OK,
        message: "Item added to cart successfully",
        body: { cart }
      }).send();
    } catch (error: any) {
      throw new BadRequestError(error.message);
    }
  }

  async getCart(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user.id;
      const cart = await this.getCartUseCase.execute(userId);
      
      new ApplicationResponse(res, {
        success: true,
        statusCode: StatusCodes.OK,
        message: "Cart retrieved successfully",
        body: { cart }
      }).send();
    } catch (error: any) {
      throw new BadRequestError(error.message);
    }
  }

  async updateCartItem(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user.id;
      const itemData: UpdateCartItemDTO = req.body;
      
      const cart = await this.updateCartItemUseCase.execute(userId, itemData);
      
      new ApplicationResponse(res, {
        success: true,
        statusCode: StatusCodes.OK,
        message: "Cart item updated successfully",
        body: { cart }
      }).send();
    } catch (error: any) {
      throw new BadRequestError(error.message);
    }
  }

  async removeFromCart(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user.id;
      const { productId } = req.params;
      
      const cart = await this.removeFromCartUseCase.execute(userId, productId);
      
      new ApplicationResponse(res, {
        success: true,
        statusCode: StatusCodes.OK,
        message: "Item removed from cart successfully",
        body: { cart }
      }).send();
    } catch (error: any) {
      throw new BadRequestError(error.message);
    }
  }

  async clearCart(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user.id;
      const success = await this.clearCartUseCase.execute(userId);
      
      new ApplicationResponse(res, {
        success: true,
        statusCode: StatusCodes.OK,
        message: success ? "Cart cleared successfully" : "Cart not found"
      }).send();
    } catch (error: any) {
      throw new BadRequestError(error.message);
    }
  }
}