import { Router } from 'express';
import { WishlistController } from '../controllers/wishlist.controller';
import { validateWishlistProductId } from '../validation/wishlist.validators';
import { wishlistProductIdMiddleware } from '../middleware/wishlist.middleware';


const wishlistRoutes = (wishlistController: WishlistController): Router => {
    const router = Router();

    router.get("/", wishlistController.getWishlist.bind(wishlistController));

    router.post("/:productId", validateWishlistProductId, wishlistProductIdMiddleware(true), wishlistController.addProdutcToWishlist.bind(wishlistController));
    
    router.delete("/product/:productId", validateWishlistProductId, wishlistProductIdMiddleware(false), wishlistController.removeProdutcFromWishlist.bind(wishlistController));
    
    router.delete("/all-product", wishlistController.removeAllProdutcFromWishlist.bind(wishlistController));
    
    return router;
}


export default wishlistRoutes;