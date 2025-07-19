import { Router } from 'express';
import { CartController } from '../controllers/cart.controller';

const cartRoutes = (cartController: CartController): Router => {
  const router = Router();

  router.post('/add', cartController.addToCart.bind(cartController));
  router.get('/', cartController.getCart.bind(cartController));
  router.put('/update', cartController.updateCartItem.bind(cartController));
  router.delete('/remove/:productId', cartController.removeFromCart.bind(cartController));
  router.delete('/clear', cartController.clearCart.bind(cartController));

  return router;
};

export default cartRoutes;