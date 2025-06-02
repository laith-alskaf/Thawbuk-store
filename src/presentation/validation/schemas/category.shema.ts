import Joi from "joi";
import { Messages } from "../../config/constant";

export const categorySchema = Joi.object({
    name: Joi.string().required().messages({
        'string.empty': Messages.CATEGORY.VALIDATION.NAME_REQUIRED_EN,
        'any.required': Messages.CATEGORY.VALIDATION.NAME_REQUIRED_EN
    }),
    description: Joi.string().required().messages({
        'string.empty': Messages.CATEGORY.VALIDATION.DESCRIPTION_REQUIRED_EN,
        'any.required': Messages.CATEGORY.VALIDATION.DESCRIPTION_REQUIRED_EN,
    }),
});
export const categoryIdSchema = Joi.object({
    categoryId: Joi.string().required().messages({
        'string.empty': Messages.CATEGORY.VALIDATION.CATEGORY_ID_REQUIRED_EN,
        'any.required': Messages.CATEGORY.VALIDATION.CATEGORY_ID_REQUIRED_EN,
    }),
});

export const updateCategorySchema = categoryIdSchema.keys({
    category: categorySchema.required().messages({
        'object.base': Messages.CATEGORY.VALIDATION.INVALID_CATEGORY_OBJECT_EN,
        'any.required': Messages.CATEGORY.VALIDATION.INVALID_CATEGORY_OBJECT_EN,
    })
})
