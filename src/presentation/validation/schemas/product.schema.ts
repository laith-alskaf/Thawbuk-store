import Joi from 'joi';
import { Messages } from '../../config/constant';




export const categoryIdSchema = Joi.object({
    categoryId: Joi.string()
        .required().messages({
            'string.empty': Messages.PRODUCT.VALIDATION.PRODUCT_VALIDATION.CATEGORY_REQUIRED_EN,
            '*': Messages.PRODUCT.VALIDATION.PRODUCT_VALIDATION.CATEGORY_REQUIRED_EN
        })
});

export const productSchema = Joi.object({
    title: Joi.string()
        .required()
        .messages({
            'string.empty': Messages.PRODUCT.VALIDATION.PRODUCT_VALIDATION.TITLE_REQUIRED_EN,
            '*': Messages.PRODUCT.VALIDATION.PRODUCT_VALIDATION.TITLE_REQUIRED_EN
        }),
    description: Joi.string()
        .required()
        .messages({
            'string.empty': Messages.PRODUCT.VALIDATION.PRODUCT_VALIDATION.DESCRIPTION_REQUIRED_EN,
            '*': Messages.PRODUCT.VALIDATION.PRODUCT_VALIDATION.DESCRIPTION_REQUIRED_EN
        }),
    price: Joi.number().min(1)
        .required()
        .messages({
            'number.min': Messages.PRODUCT.VALIDATION.PRODUCT_VALIDATION.PRICE_INVALID_EN,
            'number.base': Messages.PRODUCT.VALIDATION.PRODUCT_VALIDATION.PRICE_INVALID_EN,
            '*': Messages.PRODUCT.VALIDATION.PRODUCT_VALIDATION.PRICE_REQUIRED_EN,
        }),
    stockQuantity: Joi.number().default(0),
    images: Joi.array().items(Joi.string().uri()),
}).concat(categoryIdSchema);

export const productIdSchema = Joi.object({
    productId: Joi.string()
        .required()
        .messages({
            'string.empty': Messages.PRODUCT.VALIDATION.GENERAL_VALIDATION.PRODUCT_ID_REQUIRED_EN,
            '*': Messages.PRODUCT.VALIDATION.GENERAL_VALIDATION.PRODUCT_ID_REQUIRED_EN
        })
});

export const paginationSchema = Joi.object({
    page: Joi.number().min(1).default(1).messages({
        'number.base': Messages.PRODUCT.VALIDATION.PAGINATION_VALIDATION.PAGE_INVALID_EN,
        'number.min': Messages.PRODUCT.VALIDATION.PAGINATION_VALIDATION.PAGE_MIN_EN,
    }),
    limit: Joi.number().min(1).default(10).messages({
        'number.base': Messages.PRODUCT.VALIDATION.PAGINATION_VALIDATION.LIMIT_INVALID_EN,
        'number.min': Messages.PRODUCT.VALIDATION.PAGINATION_VALIDATION.LIMIT_MIN_EN,
    })
});

export const searchProductSchema = paginationSchema.keys({
    title: Joi.string().allow(''),
    categoryId: Joi.string().optional().messages({
        'string.empty': Messages.CATEGORY.VALIDATION.INVALID_CATEGORY_OBJECT_EN,
        '*': Messages.PRODUCT.VALIDATION.PRODUCT_VALIDATION.CATEGORY_REQUIRED_EN
    })
});
export const updateProductSchema = productIdSchema.keys({
    product: productSchema.required().messages({
        'object.base': Messages.PRODUCT.VALIDATION.GENERAL_VALIDATION.PRODUCT_DATA_REQUIRED_EN,
        '*': Messages.PRODUCT.VALIDATION.GENERAL_VALIDATION.PRODUCT_DATA_REQUIRED_EN,
    })
});

