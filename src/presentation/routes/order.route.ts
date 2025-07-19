import { Router } from 'express';
import { OrderController } from '../controllers/order.controller';

const orderRoutes = (orderController: OrderController): Router => {
  const router = Router();

  router.post('/', orderController.createOrder.bind(orderController));
  router.get('/', orderController.getUserOrders.bind(orderController));
  router.get('/:orderId', orderController.getOrder.bind(orderController));
  router.put('/:orderId/status', orderController.updateOrderStatus.bind(orderController));

  return router;
};

export default orderRoutes;