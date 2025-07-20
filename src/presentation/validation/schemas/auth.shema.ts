import Joi from "joi"
import { Messages } from "../../config/constant";


export const emailSchema = Joi.object({
    email: Joi.string().email().required().email().messages({
        'string.email': Messages.USER.VALIDATION.EMAIL_INVALID_EN,
        'any.required': Messages.USER.VALIDATION.EMAIL_REQUIRED_EN,
    }),
});

export const loginSchema = emailSchema.keys({
    password: Joi.string().min(6).required().messages({
        'string.min': Messages.USER.VALIDATION.PASSWORD_MIN_EN,
        'any.required': Messages.USER.VALIDATION.PASSWORD_REQUIRED_EN
    })
});

export const signupSchema = Joi.object({
    role: Joi.string().valid('superAdmin', 'admin', 'customer').required().messages({
        'any.only': Messages.USER.VALIDATION.ROLE_INVALID_EN,
        'any.required': Messages.USER.VALIDATION.ROLE_REQUIRED_EN,
    }),
    name: Joi.string().min(3).max(30).messages({
        'string.min': Messages.USER.VALIDATION.USERNAME_MIN_EN,
        'string.max': Messages.USER.VALIDATION.USERNAME_MAX_EN,
        'any.required': Messages.USER.VALIDATION.USERNAME_REQUIRED_EN,
    }).when('role', { is: 'customer', then: Joi.required() }),
    companyDetails: Joi.object({
        companyName: Joi.string().required().messages({
            'any.required': Messages.USER.VALIDATION.COMPANY_NAME_REQUIRED_EN,
        }),
        companyAddress: Joi.object({
            city: Joi.string().required().messages({
                'any.required': Messages.USER.VALIDATION.CITY_REQUIRED_EN,
            }),
        }),
    }).when('role', { is: 'admin', then: Joi.required() }),

    address: Joi.object({
        city: Joi.string().messages({
            'any.required': Messages.USER.VALIDATION.CITY_REQUIRED_EN,
        }).when('role', { is: 'customer', then: Joi.required() }),
    }),
    age: Joi.number().min(18).max(120).messages({
        'number.min': Messages.USER.VALIDATION.AGE_MIN_EN,
        'number.max': Messages.USER.VALIDATION.AGE_MAX_EN,
    }).when('role', { is: 'customer', then: Joi.required() }),
    gender: Joi.string().valid('male', 'female', 'other').messages({
        'any.only': Messages.USER.VALIDATION.GENDER_INVALID_EN,
    }).when('role', { is: 'customer', then: Joi.required() }),
}).concat(loginSchema);

export const codeSchema = Joi.object({
    code: Joi.string().min(6).max(6).required().messages({
        'string.min': Messages.USER.VALIDATION.CODE_MIN_EN,
        'any.required': Messages.USER.VALIDATION.CODE_REQUIRED_EN,
    }),
});

export const changePasswordSchema = emailSchema.keys({
    newPassword: Joi.string().min(6).required().messages({
        'string.min': Messages.USER.VALIDATION.NEW_PASSWORD_MIN_EN,
        'any.required': Messages.USER.VALIDATION.NEW_PASSWORD_REQUIRED_EN,
    })
});
