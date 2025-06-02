import Joi from "joi";
import { Messages } from "../../config/constant";


export const removeAndAddSchema = Joi.object({
    productId: Joi.string().required().guid({ version: ['uuidv4'] }).messages({
        'string.empty': Messages.WISHLIST.VALIDATION.PRODUCT_ID_REQUIRED_EN,
        '*': Messages.WISHLIST.VALIDATION.PRODUCT_ID_REQUIRED_EN,
    }),
});



