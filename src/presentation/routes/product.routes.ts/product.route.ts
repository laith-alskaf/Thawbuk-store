import { Router } from 'express';
import { ProductController } from '../../controllers/product.controller';
import { ProductModel } from '../../../infrastructure/database/mongodb/models/product.model';
import { checkResourceOwnership } from '../../middleware/resource-ownership.middleware';
import {
    validateProduct,
    validateProductId,
    validateUpdateProduct
} from '../../validation/product.validators';
import {
    requireOwnershipOrAdmin,
    ProductPermissions,
} from '../../middleware/role-based-access.middleware';
import multer from 'multer';


const productRouters = (productController: ProductController): Router => {
    const idKey = 'productId';
    const router = Router();
    const storage = multer.memoryStorage();
    const upload = multer({ storage: storage });

       // DELETE /user/product/:productId - حذف منتج
    // يحتاج أن يكون صاحب المنتج أو أدمن
    router.delete("/:productId", 
        validateProductId,
        requireOwnershipOrAdmin(),
        checkResourceOwnership(ProductModel, idKey), 
        productController.deleteProduct.bind(productController)
    );

    // GET /user/product - الحصول على منتجات المستخدم الحالي
    // يمكن للمستخدمين العاديين رؤية منتجاتهم، والأدمن رؤية جميع المنتجات
    router.get("/", 
        ProductPermissions.manageOwn,
        productController.getProductsByUserId.bind(productController)
    );

   

    // POST /user/product - إنشاء منتج جديد
    // يحتاج صلاحية إنشاء منتج (Admin فقط حالياً)
    router.post("/", 
        upload.array('images'), 
        ProductPermissions.create,
        validateProduct, 
        productController.createProduct.bind(productController)
    );

  
    // PUT /user/product/:productId - تعديل منتج
    // يحتاج أن يكون صاحب المنتج أو أدمن
    router.put("/:productId", 
        validateUpdateProduct,
        requireOwnershipOrAdmin(),
        checkResourceOwnership(ProductModel, idKey), 
        productController.updateProduct.bind(productController)
    );

    return router;
}
export default productRouters;

