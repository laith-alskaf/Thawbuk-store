import { Router } from 'express';
import { ProductController } from '../../controllers/product.controller';
import {
    validateGetProductByCategoryId,
    validatePaginationProduct,
    validateSearchProduct
} from '../../validation/product.validators';


const publicProductRoutes = (productController: ProductController): Router => {
    const router = Router()
    
    router.get("/", validatePaginationProduct, productController.getAllProducts.bind(productController));

    router.get("/search", validateSearchProduct, productController.searchProducts.bind(productController));

    router.get("/byCategory/:categoryId", validateGetProductByCategoryId, productController.getProductsByCategoryId.bind(productController));

    router.get("/:productId", productController.getSingleProduct.bind(productController));

    return router;

}
export default publicProductRoutes;

