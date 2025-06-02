import { createValidationMiddleware } from '../middleware/validation.middleware';
import { removeAndAddSchema } from './schemas/wishlist.shema';




export const validateWishlistProductId = createValidationMiddleware({
  schema: removeAndAddSchema,
  dataSource: 'params',
});







