import { IOrderRepository } from "../../../domain/repository/order.repository";
import { OrderInfoDTO, PaginationOrderDTO } from "../../dtos/order.dto";

export class GetUserOrdersUseCase {
  constructor(
    private readonly orderRepository: IOrderRepository
  ) {}

  async execute(userId: string, pagination: PaginationOrderDTO): Promise<{ orders: OrderInfoDTO[], total: number }> {
    const { orders, total } = await this.orderRepository.findByUserId(userId, pagination);
    
    const orderDTOs = orders.map(order => ({
      _id: order._id,
      userId: order.userId,
      items: order.items.map(item => ({
        productId: item.productId,
        quantity: item.quantity,
        price: item.price,
        selectedSize: item.selectedSize,
        selectedColor: item.selectedColor,
        product: (item as any).productId ? {
          _id: (item as any).productId._id,
          name: (item as any).productId.name,
          images: (item as any).productId.images
        } : undefined
      })),
      totalAmount: order.totalAmount,
      shippingAddress: order.shippingAddress,
      status: order.status,
      paymentMethod: order.paymentMethod,
      paymentStatus: order.paymentStatus,
      orderNumber: order.orderNumber,
      notes: order.notes,
      createdAt: order.createdAt,
      updatedAt: order.updatedAt
    }));

    return { orders: orderDTOs, total };
  }
}