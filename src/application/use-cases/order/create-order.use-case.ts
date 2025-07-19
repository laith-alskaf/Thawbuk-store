import { IOrderRepository } from "../../../domain/repository/order.repository";
import { ICartRepository } from "../../../domain/repository/cart.repository";
import { CreateOrderDTO, OrderInfoDTO } from "../../dtos/order.dto";

export class CreateOrderUseCase {
  constructor(
    private readonly orderRepository: IOrderRepository,
    private readonly cartRepository: ICartRepository
  ) {}

  async execute(userId: string, orderData: CreateOrderDTO): Promise<OrderInfoDTO> {
    const order = await this.orderRepository.create(userId, orderData);
    
    // مسح سلة التسوق بعد إنشاء الطلب
    await this.cartRepository.clearCart(userId);
    
    return {
      _id: order._id,
      userId: order.userId,
      items: order.items.map(item => ({
        productId: item.productId,
        quantity: item.quantity,
        price: item.price,
        selectedSize: item.selectedSize,
        selectedColor: item.selectedColor
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
    };
  }
}