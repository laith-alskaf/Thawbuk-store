import { ICartRepository } from "../../../domain/repository/cart.repository";
import { AddItemToCartDTO, CartInfoDTO } from "../../dtos/cart.dto";
import { ProductRepository } from "../../../domain/repository/product.repository";

export class AddItemToCartUseCase {
  constructor(
    private readonly cartRepository: ICartRepository,
    private readonly productRepository: ProductRepository
  ) {}

  async execute(userId: string, itemData: AddItemToCartDTO): Promise<CartInfoDTO> {
    // التحقق من وجود المنتج
    const product = await this.productRepository.findById(itemData.productId);
    if (!product) {
      throw new Error("Product not found");
    }

    // التحقق من المخزون
    if (product.stock < itemData.quantity) {
      throw new Error("Insufficient stock");
    }

    const cart = await this.cartRepository.addItem(userId, itemData);
    
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