import { Router } from 'express';
import { AuthController } from '../controllers/auth.controller';
import {
    validateSignup,
    validateLogin,
    validateForgotPass,
    validateVerifyEmail,
    validateChangePassword
} from '../validation/auth.validators';



const authRoutes = (authController: AuthController): Router => {
    const router = Router();

    router.post("/register", validateSignup, authController.register.bind(authController));

    router.post("/login", validateLogin, authController.login.bind(authController));

    router.post("/forgot-password", validateForgotPass, authController.forgotPassword.bind(authController));

    router.post("/change-password", validateChangePassword, authController.changePassword.bind(authController));

    router.post("/verify-email", validateVerifyEmail, authController.verifyEmail.bind(authController));

    router.post("/logout", authController.logout.bind(authController));
    return router;
};

export default authRoutes;
