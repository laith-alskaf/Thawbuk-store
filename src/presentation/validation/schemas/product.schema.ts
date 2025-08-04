import Joi from 'joi';
import { Messages } from '../../config/constant';




export const categoryIdSchema = Joi.object({
    categoryId: Joi.string()
        .required().messages({
            'string.empty': Messages.PRODUCT.VALIDATION.PRODUCT_VALIDATION.CATEGORY_REQUIRED,
            '*': Messages.PRODUCT.VALIDATION.PRODUCT_VALIDATION.CATEGORY_REQUIRED
        })
});

export const productSchema = Joi.object({
    name: Joi.string()
        .required()
        .messages({
            'string.empty': Messages.PRODUCT.VALIDATION.PRODUCT_VALIDATION.TITLE_REQUIRED,
            '*': Messages.PRODUCT.VALIDATION.PRODUCT_VALIDATION.TITLE_REQUIRED
        }),
    description: Joi.string()
        .required()
        .messages({
            'string.empty': Messages.PRODUCT.VALIDATION.PRODUCT_VALIDATION.DESCRIPTION_REQUIRED,
            '*': Messages.PRODUCT.VALIDATION.PRODUCT_VALIDATION.DESCRIPTION_REQUIRED
        }),
    price: Joi.number().min(1)
        .required()
        .messages({
            'number.min': Messages.PRODUCT.VALIDATION.PRODUCT_VALIDATION.PRICE_INVALID,
            'number.base': Messages.PRODUCT.VALIDATION.PRODUCT_VALIDATION.PRICE_INVALID,
            '*': Messages.PRODUCT.VALIDATION.PRODUCT_VALIDATION.PRICE_REQUIRED,
        }),
    stock: Joi.number().default(0),
}).concat(categoryIdSchema);

export const productIdSchema = Joi.object({
    productId: Joi.string()
        .required()
        .messages({
            'string.empty': Messages.PRODUCT.VALIDATION.GENERAL_VALIDATION.PRODUCT_ID_REQUIRED,
            '*': Messages.PRODUCT.VALIDATION.GENERAL_VALIDATION.PRODUCT_ID_REQUIRED
        })
});

export const paginationSchema = Joi.object({
    page: Joi.number().min(1).default(1).messages({
        'number.base': Messages.PRODUCT.VALIDATION.PAGINATION_VALIDATION.PAGE_INVALID,
        'number.min': Messages.PRODUCT.VALIDATION.PAGINATION_VALIDATION.PAGE_MIN,
    }),
    limit: Joi.number().min(1).default(10).messages({
        'number.base': Messages.PRODUCT.VALIDATION.PAGINATION_VALIDATION.LIMIT_INVALID,
        'number.min': Messages.PRODUCT.VALIDATION.PAGINATION_VALIDATION.LIMIT_MIN,
    })
});

export const searchProductSchema = paginationSchema.keys({
    title: Joi.string().allow(''),
    categoryId: Joi.string().optional().messages({
        'string.empty': Messages.CATEGORY.VALIDATION.INVALID_CATEGORY_OBJECT,
        '*': Messages.PRODUCT.VALIDATION.PRODUCT_VALIDATION.CATEGORY_REQUIRED
    })
});
export const updateProductSchema = productIdSchema.keys({
    product: productSchema.required().messages({
        'object.base': Messages.PRODUCT.VALIDATION.GENERAL_VALIDATION.PRODUCT_DATA_REQUIRED,
        '*': Messages.PRODUCT.VALIDATION.GENERAL_VALIDATION.PRODUCT_DATA_REQUIRED,
    })
});
