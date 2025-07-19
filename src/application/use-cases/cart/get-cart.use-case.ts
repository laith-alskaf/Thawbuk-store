import { ICartRepository } from "../../../domain/repository/cart.repository";
import { CartInfoDTO } from "../../dtos/cart.dto";

export class GetCartUseCase {
  constructor(
    private readonly cartRepository: ICartRepository
  ) {}

  async execute(userId: string): Promise<CartInfoDTO | null> {
    const cart = await this.cartRepository.findByUserId(userId);
    
    if (!cart) {
      return null;
    }

    return {
      _id: cart._id,
      userId: cart.userId,
      items: cart.items.map(item => ({
        productId: item.productId,
        quantity: item.quantity,
        selectedSize: item.selectedSize,
        selectedColor: item.selectedColor,
        product: (item as any).productId ? {
          _id: (item as any).productId._id,
          name: (item as any).productId.name,
          price: (item as any).productId.price,
          images: (item as any).productId.images
        } : undefined
      })),
      totalAmount: cart.totalAmount,
      totalItems: cart.items.reduce((sum, item) => sum + item.quantity, 0)
    };
  }
}