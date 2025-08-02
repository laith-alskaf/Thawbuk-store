import { Router } from 'express';
import { ProductController } from '../../controllers/product.controller';
import { ProductModel } from '../../../infrastructure/database/mongodb/models/product.model';
import { checkResourceOwnership } from '../../middleware/resource-ownership.middleware';
import {
    validateProduct,
    validateProductId,
    validateUpdateProduct
} from '../../validation/product.validators';
import multer from 'multer';


const productRouters = (productController: ProductController): Router => {
    const idKey = 'productId';
    const router = Router()
    const storage = multer.memoryStorage()
    const upload = multer({ storage: storage});
    // router.post("/create", upload.single("image"), validateProduct, productController.createProduct.bind(productController));

    router.get("/", productController.getProductsByUserId.bind(productController));

    router.post("/", upload.array('images'), validateProduct, productController.createProduct.bind(productController));

    router.delete("/:productId", validateProductId, checkResourceOwnership(ProductModel, idKey), productController.deleteProduct.bind(productController));

    router.put("/:productId", validateUpdateProduct, checkResourceOwnership(ProductModel, idKey), productController.updateProduct.bind(productController));

    return router;

}
export default productRouters;

