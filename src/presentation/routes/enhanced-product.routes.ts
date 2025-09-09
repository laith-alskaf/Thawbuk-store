import { Router } from 'express';
import { EnhancedProductController } from '../controllers/enhanced-product.controller';
import { ProductModel } from '../../infrastructure/database/mongodb/models/product.model';
import { checkResourceOwnership } from '../middleware/resource-ownership.middleware';
import {
    validateProduct,
    validateProductId,
    validateUpdateProduct,
    validateGetProductByCategoryId,
    validatePaginationParams
} from '../validation/product.validators';
import {
    requireAdmin,
    requireOwnershipOrAdmin,
    ProductPermissions,
} from '../middleware/role-based-access.middleware';
import multer from 'multer';

const enhancedProductRoutes = (enhancedProductController: EnhancedProductController): Router => {
    const idKey = 'productId';
    const router = Router();
    const storage = multer.memoryStorage();
    const upload = multer({ 
        storage: storage,
        limits: {
            fileSize: 5 * 1024 * 1024, // 5MB limit per file
            files: 10 // Maximum 10 files
        },
        fileFilter: (req, file, cb) => {
            // Only allow image files
            if (file.mimetype.startsWith('image/')) {
                cb(null, true);
            } else {
                cb(new Error('Only image files are allowed'));
            }
        }
    });

    // Public Routes (لا تحتاج مصادقة)
    
    // GET /product - الحصول على جميع المنتجات (عام)
    router.get("/", 
        validatePaginationParams,
        enhancedProductController.getAllProducts.bind(enhancedProductController)
    );

    // GET /product/:productId - الحصول على منتج واحد (عام)
    router.get("/:productId", 
        validateProductId,
        enhancedProductController.getSingleProduct.bind(enhancedProductController)
    );

    // GET /product/category/:categoryId - المنتجات حسب الفئة (عام)
    router.get("/category/:categoryId", 
        validateGetProductByCategoryId,
        enhancedProductController.getProductsByCategoryId.bind(enhancedProductController)
    );

    // GET /product/filter - فلترة المنتجات (عام)
    router.get("/filter", 
        enhancedProductController.filterProducts.bind(enhancedProductController)
    );

    // GET /product/search - البحث في المنتجات (عام)
    router.get("/search", 
        validatePaginationParams,
        enhancedProductController.searchProducts.bind(enhancedProductController)
    );

    // GET /product/enhanced-search - البحث المحسن (عام)
    router.get("/enhanced-search", 
        enhancedProductController.enhancedSearch.bind(enhancedProductController)
    );

    // GET /product/autocomplete - اقتراحات الإكمال التلقائي (عام)
    router.get("/autocomplete", 
        enhancedProductController.getAutocompleteSuggestions.bind(enhancedProductController)
    );

    return router;
};

// Protected User Routes (تحتاج مصادقة)
const enhancedUserProductRoutes = (enhancedProductController: EnhancedProductController): Router => {
    const idKey = 'productId';
    const router = Router();
    const storage = multer.memoryStorage();
    const upload = multer({ 
        storage: storage,
        limits: {
            fileSize: 5 * 1024 * 1024, // 5MB limit per file
            files: 10 // Maximum 10 files
        },
        fileFilter: (req, file, cb) => {
            // Only allow image files
            if (file.mimetype.startsWith('image/')) {
                cb(null, true);
            } else {
                cb(new Error('Only image files are allowed'));
            }
        }
    });

    // Apply authentication middleware to all routes
   // DELETE /user/product/:productId - حذف منتج
    // يحتاج أن يكون صاحب المنتج أو أدمن
    router.delete("/:productId", 
        validateProductId,
        requireOwnershipOrAdmin(),
        // checkResourceOwnership(ProductModel, idKey), 
        enhancedProductController.deleteProduct.bind(enhancedProductController)
    );
    // GET /user/product - الحصول على منتجات المستخدم الحالي
    // يمكن للمستخدمين العاديين رؤية منتجاتهم، والأدمن رؤية جميع المنتجات
    router.get("/", 
        validatePaginationParams,
        ProductPermissions.manageOwn,
        enhancedProductController.getProductsByUserId.bind(enhancedProductController)
    );

    // POST /user/product - إنشاء منتج جديد
    // يحتاج صلاحية إنشاء منتج (Admin فقط حالياً)
    router.post("/", 
        upload.array('images', 10), // Maximum 10 images
        validateProduct,
        ProductPermissions.create,
        enhancedProductController.createProduct.bind(enhancedProductController)
    );

    // PUT /user/product/:productId - تعديل منتج
    // يحتاج أن يكون صاحب المنتج أو أدمن
    router.put("/:productId", 
        upload.array('images', 10), // Optional images for update
        validateProductId,
        validateUpdateProduct,
        requireOwnershipOrAdmin(),
        checkResourceOwnership(ProductModel, idKey), 
        enhancedProductController.updateProduct.bind(enhancedProductController)
    );

 

    return router;
};

// Admin Only Routes (للأدمن فقط)
const enhancedAdminProductRoutes = (enhancedProductController: EnhancedProductController): Router => {
    const router = Router();

    // Apply authentication and admin middleware to all routes
    router.use(requireAdmin);

    // GET /admin/product/all - جميع المنتجات للأدمن
    router.get("/all", 
        validatePaginationParams,
        enhancedProductController.getAllProducts.bind(enhancedProductController)
    );

    // GET /admin/product/search-analytics - إحصائيات البحث
    router.get("/search-analytics", 
        enhancedProductController.getSearchAnalytics.bind(enhancedProductController)
    );

    // DELETE /admin/product/clear-search-cache - مسح ذاكرة البحث المؤقت
    router.delete("/clear-search-cache", 
        enhancedProductController.clearSearchCache.bind(enhancedProductController)
    );

    // Additional admin-only routes can be added here
    // مثل إحصائيات المنتجات، المنتجات المعلقة للمراجعة، إلخ

    return router;
};

export { 
    enhancedProductRoutes, 
    enhancedUserProductRoutes, 
    enhancedAdminProductRoutes 
};