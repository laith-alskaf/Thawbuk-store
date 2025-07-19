import { IOrder } from "../entity/order";
import { CreateOrderDTO, OrderFilterDTO, PaginationOrderDTO } from "../../application/dtos/order.dto";

export interface IOrderRepository {
  create(userId: string, orderData: CreateOrderDTO): Promise<IOrder>;
  findById(orderId: string): Promise<IOrder | null>;
  findByUserId(userId: string, pagination: PaginationOrderDTO): Promise<{ orders: IOrder[], total: number }>;
  findAll(pagination: PaginationOrderDTO, filter?: OrderFilterDTO): Promise<{ orders: IOrder[], total: number }>;
  updateStatus(orderId: string, status: IOrder['status']): Promise<IOrder | null>;
  updatePaymentStatus(orderId: string, paymentStatus: IOrder['paymentStatus']): Promise<IOrder | null>;
  findByOrderNumber(orderNumber: string): Promise<IOrder | null>;
  delete(orderId: string): Promise<boolean>;
}