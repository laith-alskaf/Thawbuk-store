import { createValidationMiddleware } from "../middleware/validation.middleware";
import {
  categoryIdSchema,
  paginationSchema,
  productIdSchema,
  productSchema,
  searchProductSchema,
  updateProductSchema
} from "./schemas/product.schema";


export const validateProduct = createValidationMiddleware({
  schema: productSchema,
  dataSource: 'body',
});

export const validateProductId = createValidationMiddleware({
  schema: productIdSchema,
  dataSource: 'params'
});


export const validateUpdateProduct = createValidationMiddleware({
  schema: updateProductSchema,
  dataSource: 'composite',
});

export const validatePaginationProduct = createValidationMiddleware({
  schema: paginationSchema,
  dataSource: 'query'
});

export const validateSearchProduct = createValidationMiddleware({
  schema: searchProductSchema,
  dataSource: 'query',
});

export const validateGetProductByCategoryId = createValidationMiddleware({
  schema: categoryIdSchema,
  dataSource: 'params',
});







