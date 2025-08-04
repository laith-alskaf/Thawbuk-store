import { Router } from 'express';
import { CategoryController } from '../../controllers/category.controller';
import { validateCategoryId } from '../../validation/category.validators';


const publicCategoryRouters = (categoryController: CategoryController): Router => {
    const router = Router();

    router.get("/",
        categoryController.getAllCategory.bind(categoryController),
    );

    router.get("/:categoryId", validateCategoryId,
        categoryController.getSingleCategory.bind(categoryController)
    );

    return router;

}

export default publicCategoryRouters;