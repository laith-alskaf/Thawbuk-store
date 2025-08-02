import Joi from "joi";
import { Messages } from "../../config/constant";

export const updateUserInfoShema = Joi.object({
    name: Joi.string().min(3).max(30).messages({
        'string.min': Messages.USER.VALIDATION.USERNAME_MIN_EN,
        'string.max': Messages.USER.VALIDATION.USERNAME_MAX_EN,
        'any.required': Messages.GENERAL.INVALID_PARAMETERS_EN
    }),
    email: Joi.string().email().messages({
        'string.email': Messages.USER.VALIDATION.EMAIL_INVALID_EN,
        'any.required': Messages.GENERAL.INVALID_PARAMETERS_EN
    }),
    companyDetails: Joi.object({
        companyName: Joi.string().messages({
            'any.required': Messages.USER.VALIDATION.COMPANY_NAME_REQUIRED_EN,
        }),
    }),
    address: Joi.object({
        city: Joi.string().messages({
            'any.required': Messages.USER.VALIDATION.CITY_REQUIRED_EN,
        }),
        street: Joi.string().messages({
            'any.required': Messages.USER.VALIDATION.STREET_REQUIRED_EN,
        }),
    }),
    age: Joi.number().min(18).max(120).messages({
        'number.min': Messages.USER.VALIDATION.AGE_MIN_EN,
        'number.max': Messages.USER.VALIDATION.AGE_MAX_EN,
    }),
    gender: Joi.string().valid('male', 'female', 'other').messages({
        'any.only': Messages.USER.VALIDATION.GENDER_INVALID_EN,
    }),
});