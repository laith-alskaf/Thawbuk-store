import { ICartRepository } from "../../../domain/repository/cart.repository";
import { UpdateCartItemDTO, CartInfoDTO } from "../../dtos/cart.dto";

export class UpdateCartItemUseCase {
  constructor(
    private readonly cartRepository: ICartRepository
  ) {}

  async execute(userId: string, itemData: UpdateCartItemDTO): Promise<CartInfoDTO> {
    const cart = await this.cartRepository.updateItem(userId, itemData);
    
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