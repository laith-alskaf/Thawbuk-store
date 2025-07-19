import { ICart } from "../entity/cart";
import { AddItemToCartDTO, UpdateCartItemDTO } from "../../application/dtos/cart.dto";

export interface ICartRepository {
  create(cart: Partial<ICart>): Promise<ICart>;
  findByUserId(userId: string): Promise<ICart | null>;
  addItem(userId: string, item: AddItemToCartDTO): Promise<ICart>;
  updateItem(userId: string, item: UpdateCartItemDTO): Promise<ICart>;
  removeItem(userId: string, productId: string): Promise<ICart>;
  clearCart(userId: string): Promise<boolean>;
  delete(cartId: string): Promise<boolean>;
}