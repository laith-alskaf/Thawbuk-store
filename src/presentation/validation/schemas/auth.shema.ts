import Joi from "joi"
import { Messages } from "../../config/constant";


export const emailSchema = Joi.object({
    email: Joi.string().email().required().email().messages({
        'string.email': Messages.USER.VALIDATION.EMAIL_INVALID,
        'any.required': Messages.USER.VALIDATION.EMAIL_REQUIRED,
    }),
});

export const loginSchema = emailSchema.keys({
    password: Joi.string().min(6).required().messages({
        'string.min': Messages.USER.VALIDATION.PASSWORD_MIN,
        'any.required': Messages.USER.VALIDATION.PASSWORD_REQUIRED
    })
});

export const signupSchema = Joi.object({
    role: Joi.string().valid('superAdmin', 'admin', 'customer').required().messages({
        'any.only': Messages.USER.VALIDATION.ROLE_INVALID,
        'any.required': Messages.USER.VALIDATION.ROLE_REQUIRED,
    }),
    name: Joi.string().min(3).max(30).messages({
        'string.min': Messages.USER.VALIDATION.USERNAME_MIN,
        'string.max': Messages.USER.VALIDATION.USERNAME_MAX,
        'any.required': Messages.USER.VALIDATION.USERNAME_REQUIRED,
    }).when('role', { is: 'customer', then: Joi.required() }),

    companyDetails: Joi.object({
        companyName: Joi.string().required().messages({
            'any.required': Messages.USER.VALIDATION.COMPANY_NAME_REQUIRED,
        }),
        companyAddress: Joi.object({
            city: Joi.string().required().messages({
                'any.required': Messages.USER.VALIDATION.CITY_REQUIRED,
            }),
        }),
    }).when('role', { is: 'admin', then: Joi.required() }),

    address: Joi.object({
        city: Joi.string().messages({
            'any.required': Messages.USER.VALIDATION.CITY_REQUIRED,
        }).when('role', { is: 'customer', then: Joi.required(), otherwise: Joi.optional() }),
    }),
    age: Joi.number().min(18).max(120).messages({
        'number.min': Messages.USER.VALIDATION.AGE_MIN,
        'number.max': Messages.USER.VALIDATION.AGE_MAX,
    }).when('role', { is: 'customer', then: Joi.required() }),
    gender: Joi.string().valid('male', 'female', 'other').messages({
        'any.only': Messages.USER.VALIDATION.GENDER_INVALID,
    }).when('role', { is: 'customer', then: Joi.required() }),
}).concat(loginSchema);

export const codeSchema = Joi.object({
    otpCode: Joi.string().min(6).max(6).required().messages({
        'string.min': Messages.USER.VALIDATION.CODE_MIN,
        'any.required': Messages.USER.VALIDATION.CODE_REQUIRED,
    }),
});

export const changePasswordSchema = emailSchema.keys({
    newPassword: Joi.string().min(6).required().messages({
        'string.min': Messages.USER.VALIDATION.NEW_PASSWORD_MIN,
        'any.required': Messages.USER.VALIDATION.NEW_PASSWORD_REQUIRED,
    })
});
