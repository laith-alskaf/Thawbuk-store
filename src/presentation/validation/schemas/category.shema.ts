import Joi from "joi";
import { Messages } from "../../config/constant";

export const categorySchema = Joi.object({
    name: Joi.string().required().messages({
        'string.empty': Messages.CATEGORY.VALIDATION.NAME_REQUIRED,
        'any.required': Messages.CATEGORY.VALIDATION.NAME_REQUIRED
    }),
    description: Joi.string().required().messages({
        'string.empty': Messages.CATEGORY.VALIDATION.DESCRIPTION_REQUIRED,
        'any.required': Messages.CATEGORY.VALIDATION.DESCRIPTION_REQUIRED,
    }),
});
export const categoryIdSchema = Joi.object({
    categoryId: Joi.string().required().messages({
        'string.empty': Messages.CATEGORY.VALIDATION.CATEGORY_ID_REQUIRED,
        'any.required': Messages.CATEGORY.VALIDATION.CATEGORY_ID_REQUIRED,
    }),
});

export const updateCategorySchema = categoryIdSchema.keys({
    category: categorySchema.required().messages({
        'object.base': Messages.CATEGORY.VALIDATION.INVALID_CATEGORY_OBJECT,
        'any.required': Messages.CATEGORY.VALIDATION.INVALID_CATEGORY_OBJECT,
    })
})
