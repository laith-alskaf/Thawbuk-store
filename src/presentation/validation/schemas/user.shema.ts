import Joi from "joi";
import { Messages } from "../../config/constant";

export const updateUserInfoShema = Joi.object({
    name: Joi.string().min(3).max(30).optional().messages({
        'string.min': Messages.USER.VALIDATION.USERNAME_MIN,
        'string.max': Messages.USER.VALIDATION.USERNAME_MAX,
    }),
    email: Joi.string().email().optional().messages({
        'string.email': Messages.USER.VALIDATION.EMAIL_INVALID,
    }),
    companyDetails: Joi.object({
        companyName: Joi.string().optional().messages({
            'any.required': Messages.USER.VALIDATION.COMPANY_NAME_REQUIRED,
        }),
        companyDescription: Joi.string().optional().allow(''),
        companyAddress: Joi.object({
            city: Joi.string().required(),
            street: Joi.string().optional().allow(''),
        }).optional(),
        socialLinks: Joi.object({
            facebook: Joi.string().uri().optional().allow(''),
            instagram: Joi.string().uri().optional().allow(''),
            whatsapp: Joi.string().uri().optional().allow(''),
        }).optional(),
    }).optional(),
    address: Joi.object({
        city: Joi.string().required().messages({
            'any.required': Messages.USER.VALIDATION.CITY_REQUIRED,
        }),
        street: Joi.string().optional().allow('').messages({
            'any.required': Messages.USER.VALIDATION.STREET_REQUIRED,
        }),
    }).optional(),
    age: Joi.number().min(18).max(120).optional().messages({
        'number.min': Messages.USER.VALIDATION.AGE_MIN,
        'number.max': Messages.USER.VALIDATION.AGE_MAX,
    }),
    gender: Joi.string().valid('male', 'female', 'other').optional().messages({
        'any.only': Messages.USER.VALIDATION.GENDER_INVALID,
    }),
    // Explicitly exclude role and other sensitive fields
    role: Joi.forbidden(),
    _id: Joi.forbidden(),
    password: Joi.forbidden(),
    isEmailVerified: Joi.forbidden(),
    otpCode: Joi.forbidden(),
    otpCodeExpires: Joi.forbidden(),
    createdAt: Joi.forbidden(),
    updatedAt: Joi.forbidden(),
});

export const updateSocialLinksSchema = Joi.object({
    facebook: Joi.string().uri().optional().allow('').messages({
        'string.uri': 'رابط فيسبوك غير صحيح',
    }),
    instagram: Joi.string().uri().optional().allow('').messages({
        'string.uri': 'رابط إنستغرام غير صحيح',
    }),
    whatsapp: Joi.string().uri().optional().allow('').messages({
        'string.uri': 'رابط واتساب غير صحيح',
    }),
});
