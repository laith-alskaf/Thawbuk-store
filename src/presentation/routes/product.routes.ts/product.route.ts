import { Router } from 'express';
import { ProductController } from '../../controllers/product.controller';
import { ProductModel } from '../../../infrastructure/database/mongodb/models/product.model';
import { checkResourceOwnership } from '../../middleware/resource-ownership.middleware';
import {
    validateProduct,
    validateProductId,
    validateUpdateProduct
} from '../../validation/product.validators';


const productRouters = (productController: ProductController): Router => {
    const idKey = 'productId';
    const router = Router()
    // router.post("/create", upload.single("image"), validateProduct, productController.createProduct.bind(productController));

    router.get("/", productController.getProductsByUserId.bind(productController));
    
    router.post("/", validateProduct, productController.createProduct.bind(productController));

    router.delete("/:productId", validateProductId, checkResourceOwnership(ProductModel, idKey), productController.deleteProduct.bind(productController));

    router.put("/:productId", validateUpdateProduct, checkResourceOwnership(ProductModel, idKey), productController.updateProduct.bind(productController));

    return router;

}
export default productRouters;

