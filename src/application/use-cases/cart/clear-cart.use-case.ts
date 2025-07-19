import { ICartRepository } from "../../../domain/repository/cart.repository";

export class ClearCartUseCase {
  constructor(
    private readonly cartRepository: ICartRepository
  ) {}

  async execute(userId: string): Promise<boolean> {
    return await this.cartRepository.clearCart(userId);
  }
}