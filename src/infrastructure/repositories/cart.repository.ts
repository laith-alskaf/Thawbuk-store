import { ICartRepository } from "../../domain/repository/cart.repository";
import { ICart } from "../../domain/entity/cart";
import { AddItemToCartDTO, UpdateCartItemDTO } from "../../application/dtos/cart.dto";
import { CartModel } from "../database/mongodb/models/cart.model";

export class CartRepository implements ICartRepository {
  async create(cart: Partial<ICart>): Promise<ICart> {
    const newCart = new CartModel(cart);
    await newCart.save();
    return newCart.toObject();
  }

  async findByUserId(userId: string): Promise<ICart | null> {
    const cart = await CartModel.findOne({ userId }).populate('items.productId', 'name price images').lean();
    return cart;
  }

  async addItem(userId: string, item: AddItemToCartDTO): Promise<ICart> {
    let cart = await CartModel.findOne({ userId });
    
    if (!cart) {
      cart = new CartModel({
        userId,
        items: [item],
        totalAmount: 0
      });
    } else {
      const existingItemIndex = cart.items.findIndex(
        cartItem => cartItem.productId === item.productId &&
                   cartItem.selectedSize === item.selectedSize &&
                   cartItem.selectedColor === item.selectedColor
      );
      
      if (existingItemIndex > -1) {
        cart.items[existingItemIndex].quantity += item.quantity;
      } else {
        cart.items.push(item);
      }
    }
    
    await cart.save();
    return cart.toObject();
  }

  async updateItem(userId: string, item: UpdateCartItemDTO): Promise<ICart> {
    const cart = await CartModel.findOne({ userId });
    if (!cart) {
      throw new Error("Cart not found");
    }

    const itemIndex = cart.items.findIndex(
      cartItem => cartItem.productId === item.productId &&
                 cartItem.selectedSize === item.selectedSize &&
                 cartItem.selectedColor === item.selectedColor
    );

    if (itemIndex === -1) {
      throw new Error("Item not found in cart");
    }

    if (item.quantity <= 0) {
      cart.items.splice(itemIndex, 1);
    } else {
      cart.items[itemIndex].quantity = item.quantity;
      if (item.selectedSize !== undefined) cart.items[itemIndex].selectedSize = item.selectedSize;
      if (item.selectedColor !== undefined) cart.items[itemIndex].selectedColor = item.selectedColor;
    }

    await cart.save();
    return cart.toObject();
  }

  async removeItem(userId: string, productId: string): Promise<ICart> {
    const cart = await CartModel.findOne({ userId });
    if (!cart) {
      throw new Error("Cart not found");
    }

    cart.items = cart.items.filter(item => item.productId !== productId);
    await cart.save();
    return cart.toObject();
  }

  async clearCart(userId: string): Promise<boolean> {
    const result = await CartModel.updateOne(
      { userId },
      { $set: { items: [], totalAmount: 0 } }
    );
    return result.modifiedCount > 0;
  }

  async delete(cartId: string): Promise<boolean> {
    const result = await CartModel.deleteOne({ _id: cartId });
    return result.deletedCount > 0;
  }
}