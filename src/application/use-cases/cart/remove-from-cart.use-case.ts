import { ICartRepository } from "../../../domain/repository/cart.repository";
import { CartInfoDTO } from "../../dtos/cart.dto";

export class RemoveFromCartUseCase {
  constructor(
    private readonly cartRepository: ICartRepository
  ) {}

  async execute(userId: string, productId: string): Promise<CartInfoDTO> {
    const cart = await this.cartRepository.removeItem(userId, productId);
    
    return {
      _id: cart._id,
      userId: cart.userId,
      items: cart.items.map(item => ({
        productId: item.productId,
        quantity: item.quantity,
        selectedSize: item.selectedSize,
        selectedColor: item.selectedColor
      })),
      totalAmount: cart.totalAmount,
      totalItems: cart.items.reduce((sum, item) => sum + item.quantity, 0)
    };
  }
}