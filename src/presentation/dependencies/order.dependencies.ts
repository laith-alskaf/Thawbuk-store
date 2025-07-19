import { OrderController } from "../controllers/order.controller";
import { IOrderRepository } from "../../domain/repository/order.repository";
import { ICartRepository } from "../../domain/repository/cart.repository";
import {
  CreateOrderUseCase,
  GetOrderByIdUseCase,
  GetUserOrdersUseCase,
  UpdateOrderStatusUseCase
} from "../../application/use-cases/order";

interface OrderDependenciesParams {
  orderRepository: IOrderRepository;
  cartRepository: ICartRepository;
}

export const OrderDependencies = ({
  orderRepository,
  cartRepository
}: OrderDependenciesParams): OrderController => {

  const createOrderUseCase = new CreateOrderUseCase(orderRepository, cartRepository);
  const getOrderByIdUseCase = new GetOrderByIdUseCase(orderRepository);
  const getUserOrdersUseCase = new GetUserOrdersUseCase(orderRepository);
  const updateOrderStatusUseCase = new UpdateOrderStatusUseCase(orderRepository);

  return new OrderController(
    createOrderUseCase,
    getOrderByIdUseCase,
    getUserOrdersUseCase,
    updateOrderStatusUseCase
  );
};