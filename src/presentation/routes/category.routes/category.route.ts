import { Router } from 'express';
import { CategoryController } from '../../controllers/category.controller';
import {
    validateCategory,
    validateCategoryId,
    validateUpdateCategory
} from '../../validation/category.validators';
import { CategoryModel } from '../../../infrastructure/database/mongodb/models/category.model';
import { checkResourceOwnership } from '../../middleware/resource-ownership.middleware';
import multer from 'multer';



const categoryRouters = (categoryController: CategoryController): Router => {
    const router = Router();
    const idKey = 'categoryId';
    const storage = multer.memoryStorage()
    const upload = multer({ storage: storage });
    
    router.post("/", upload.single('image'),
        validateCategory,
        categoryController.createCategory.bind(categoryController)
    );

    router.delete("/:categoryId",
        validateCategoryId,
        checkResourceOwnership(CategoryModel, idKey),
        categoryController.deleteCategory.bind(categoryController)
    );
    router.put("/:categoryId",
        validateUpdateCategory,
        checkResourceOwnership(CategoryModel, idKey),
        categoryController.updateCategory.bind(categoryController)
    );

    return router;

}

export default categoryRouters;