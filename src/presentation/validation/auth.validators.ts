import { changePasswordSchema, codeSchema, emailSchema, loginSchema, signupSchema } from './schemas/auth.shema';
import { createValidationMiddleware } from '../middleware/validation.middleware';

export const validateSignup = createValidationMiddleware({
  schema: signupSchema,
  dataSource: 'body',
});

export const validateLogin = createValidationMiddleware({
  schema: loginSchema,
  dataSource: 'body',
});


export const validateForgotPass = createValidationMiddleware({
  schema: emailSchema,
  dataSource: 'body',
});

export const validateVerifyEmail = createValidationMiddleware({
  schema: codeSchema,
  dataSource: 'body',
});

export const validateChangePassword = createValidationMiddleware({
  schema: changePasswordSchema,
  dataSource: 'body',
});