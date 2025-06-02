import { createValidationMiddleware } from '../middleware/validation.middleware';
import { categoryIdSchema, categorySchema, updateCategorySchema } from './schemas/category.shema';


export const validateCategory = createValidationMiddleware({
  schema: categorySchema,
  dataSource: 'body',
});


export const validateCategoryId = createValidationMiddleware({
  schema: categoryIdSchema,
  dataSource: 'params',
});
export const validateUpdateCategory = createValidationMiddleware({
  schema: updateCategorySchema,
  dataSource: 'composite',
});
