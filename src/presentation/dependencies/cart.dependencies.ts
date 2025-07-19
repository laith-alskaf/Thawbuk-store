import { CartController } from "../controllers/cart.controller";
import { ICartRepository } from "../../domain/repository/cart.repository";
import { ProductRepository } from "../../domain/repository/product.repository";
import {
  AddItemToCartUseCase,
  GetCartUseCase,
  UpdateCartItemUseCase,
  RemoveFromCartUseCase,
  ClearCartUseCase
} from "../../application/use-cases/cart";

interface CartDependenciesParams {
  cartRepository: ICartRepository;
  productRepository: ProductRepository;
}

export const CartDependencies = ({
  cartRepository,
  productRepository
}: CartDependenciesParams): CartController => {

  const addItemToCartUseCase = new AddItemToCartUseCase(cartRepository, productRepository);
  const getCartUseCase = new GetCartUseCase(cartRepository);
  const updateCartItemUseCase = new UpdateCartItemUseCase(cartRepository);
  const removeFromCartUseCase = new RemoveFromCartUseCase(cartRepository);
  const clearCartUseCase = new ClearCartUseCase(cartRepository);

  return new CartController(
    addItemToCartUseCase,
    getCartUseCase,
    updateCartItemUseCase,
    removeFromCartUseCase,
    clearCartUseCase
  );
};