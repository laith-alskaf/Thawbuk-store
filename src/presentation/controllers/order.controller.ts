import { Request, Response } from 'express';
import { CreateOrderDTO, PaginationOrderDTO } from '../../application/dtos/order.dto';
import { Messages, StatusCodes } from '../config/constant';
import {
  CreateOrderUseCase,
  GetOrderByIdUseCase,
  GetUserOrdersUseCase,
  UpdateOrderStatusUseCase
} from '../../application/use-cases/order';
import { ApplicationResponse } from '../../application/response/application-resposne';
import { BadRequestError } from '../../application/errors/application-error';

export class OrderController {
  constructor(
    private readonly createOrderUseCase: CreateOrderUseCase,
    private readonly getOrderByIdUseCase: GetOrderByIdUseCase,
    private readonly getUserOrdersUseCase: GetUserOrdersUseCase,
    private readonly updateOrderStatusUseCase: UpdateOrderStatusUseCase
  ) {}

  async createOrder(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user.id;
      const orderData: CreateOrderDTO = req.body;
      
      const order = await this.createOrderUseCase.execute(userId, orderData);
      
      new ApplicationResponse(res, {
        success: true,
        statusCode: StatusCodes.CREATED,
        message: "Order created successfully",
        body: { order }
      }).send();
    } catch (error: any) {
      throw new BadRequestError(error.message);
    }
  }

  async getOrder(req: Request, res: Response): Promise<void> {
    try {
      const { orderId } = req.params;
      const order = await this.getOrderByIdUseCase.execute(orderId);
      
      if (!order) {
        throw new BadRequestError("Order not found");
      }
      
      new ApplicationResponse(res, {
        success: true,
        statusCode: StatusCodes.OK,
        message: "Order retrieved successfully",
        body: { order }
      }).send();
    } catch (error: any) {
      throw new BadRequestError(error.message);
    }
  }

  async getUserOrders(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user.id;
      const { page = 1, limit = 10 } = req.query;
      
      const pagination: PaginationOrderDTO = {
        page: parseInt(page as string),
        limit: parseInt(limit as string)
      };
      
      const { orders, total } = await this.getUserOrdersUseCase.execute(userId, pagination);
      
      new ApplicationResponse(res, {
        success: true,
        statusCode: StatusCodes.OK,
        message: "Orders retrieved successfully",
        body: {
          currentPage: pagination.page,
          totalPages: Math.ceil(total / pagination.limit),
          totalItems: total,
          orders
        }
      }).send();
    } catch (error: any) {
      throw new BadRequestError(error.message);
    }
  }

  async updateOrderStatus(req: Request, res: Response): Promise<void> {
    try {
      const { orderId } = req.params;
      const { status } = req.body;
      
      const success = await this.updateOrderStatusUseCase.execute(orderId, status);
      
      if (!success) {
        throw new BadRequestError("Order not found or update failed");
      }
      
      new ApplicationResponse(res, {
        success: true,
        statusCode: StatusCodes.OK,
        message: "Order status updated successfully"
      }).send();
    } catch (error: any) {
      throw new BadRequestError(error.message);
    }
  }
}