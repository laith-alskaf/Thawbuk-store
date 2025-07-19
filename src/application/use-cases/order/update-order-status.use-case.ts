import { IOrderRepository } from "../../../domain/repository/order.repository";
import { IOrder } from "../../../domain/entity/order";

export class UpdateOrderStatusUseCase {
  constructor(
    private readonly orderRepository: IOrderRepository
  ) {}

  async execute(orderId: string, status: IOrder['status']): Promise<boolean> {
    const updatedOrder = await this.orderRepository.updateStatus(orderId, status);
    return !!updatedOrder;
  }
}